#!/usr/bin/env python3
"""Watch the Modules enumeration gate and retain its Xcode result bundle.

The observer copies the result into private run staging as soon as the gate
finishes. The workflow publishes that staged copy after canonical verification,
so diagnostic files cannot affect the verifier's evidence checks.
"""

from __future__ import annotations

import argparse
import json
import os
import select
import signal
import stat
import subprocess
import sys
import tempfile
import time
import traceback
from dataclasses import dataclass
from pathlib import Path
from typing import Literal
from urllib.parse import quote_from_bytes


MAX_CANDIDATES = 8
SUMMARY_TIMEOUT_SECONDS = 4
SUMMARY_LIMIT_BYTES = 65_536
INVENTORY_TIMEOUT_SECONDS = 5
MAX_BUNDLE_FILES = 10_000
MAX_BUNDLE_BYTES = 512 * 1024 * 1024
MAX_COPY_SECONDS = 45
MAX_LOG_TAIL_BYTES = 1024 * 1024
MAX_CAPTURE_RECORD_BYTES = 16 * 1024
MAX_OBSERVER_SECONDS = 2 * 60 * 60
OBSERVER_POLL_SECONDS = 0.25
GATE_MARKER_READ_RETRY_SECONDS = 0.5
GATE_MARKER_READ_RETRY_INTERVAL_SECONDS = 0.025
GATE_MARKER_MAX_BYTES = 64

GateMarkerState = Literal["not_run", "in_progress", "completed"]

STAGING_DIRECTORY = "diagnostic-staging"
CAPTURE_DIRECTORY = "enumeration-capture"
CAPTURE_RECORD = "capture-record.json"
STAGED_BUNDLE = "enumerate_Modules.xcresult"
RESULT_BUNDLE_PREFIX = "Test-Modules-"


class CaptureProblem(Exception):
    """A bounded capture could not identify or retain its result bundle."""


@dataclass
class BundleCandidate:
    name: str
    kind: str
    device: int | None
    inode: int | None


def status_line(state: str, **details: object) -> str:
    suffix = " ".join(f"{key}={value}" for key, value in details.items())
    return f"enumeration_xcresult_capture={state}" + (f" {suffix}" if suffix else "")


def _alarm_handler(_signum: int, _frame: object) -> None:
    raise TimeoutError


def _directory_flags() -> int:
    directory = getattr(os, "O_DIRECTORY", 0)
    nofollow = getattr(os, "O_NOFOLLOW", 0)
    if not directory or not nofollow:
        raise CaptureProblem("inspection_failed reason=no_follow_directory_support")
    return os.O_RDONLY | directory | nofollow


def _same_identity(first: os.stat_result, second: os.stat_result) -> bool:
    return (first.st_dev, first.st_ino) == (second.st_dev, second.st_ino)


def _fingerprint(info: os.stat_result) -> tuple[int, int, int, int, int]:
    return (
        info.st_dev,
        info.st_ino,
        info.st_size,
        getattr(info, "st_mtime_ns", int(info.st_mtime * 1_000_000_000)),
        getattr(info, "st_ctime_ns", int(info.st_ctime * 1_000_000_000)),
    )


def _open_build_root(build_root: Path) -> tuple[Path, int]:
    root = Path(os.path.abspath(build_root))
    try:
        before = os.lstat(root)
        if stat.S_ISLNK(before.st_mode) or not stat.S_ISDIR(before.st_mode):
            raise CaptureProblem("inspection_failed reason=build_root_not_directory")
        descriptor = os.open(root, _directory_flags())
        after = os.fstat(descriptor)
        if not _same_identity(before, after):
            os.close(descriptor)
            raise CaptureProblem("inspection_failed reason=build_root_replaced")
        return root, descriptor
    except CaptureProblem:
        raise
    except FileNotFoundError as error:
        raise CaptureProblem("missing reason=build_root_missing") from error
    except OSError as error:
        raise CaptureProblem("inspection_failed reason=build_root_open") from error


def _open_child_directory(
    parent_fd: int,
    name: str,
    *,
    expected_identity: tuple[int, int] | None = None,
    missing_reason: str = "directory_missing",
    failure_reason: str = "directory_open",
) -> int:
    try:
        before = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
        if stat.S_ISLNK(before.st_mode):
            raise CaptureProblem(f"inspection_failed reason={failure_reason}_symlink")
        if not stat.S_ISDIR(before.st_mode):
            raise CaptureProblem(f"inspection_failed reason={failure_reason}_not_directory")
        if expected_identity is not None and (before.st_dev, before.st_ino) != expected_identity:
            raise CaptureProblem("inspection_failed reason=reported_bundle_replaced")
        descriptor = os.open(name, _directory_flags(), dir_fd=parent_fd)
        after = os.fstat(descriptor)
        if not _same_identity(before, after):
            os.close(descriptor)
            raise CaptureProblem(f"inspection_failed reason={failure_reason}_replaced")
        return descriptor
    except CaptureProblem:
        raise
    except FileNotFoundError as error:
        raise CaptureProblem(f"missing reason={missing_reason}") from error
    except OSError as error:
        raise CaptureProblem(f"inspection_failed reason={failure_reason}") from error


def _open_directory_chain(
    build_root: Path,
    components: tuple[str, ...],
    *,
    create: bool = False,
) -> int:
    _root, descriptor = _open_build_root(build_root)
    try:
        for component in components:
            if create:
                try:
                    os.mkdir(component, 0o700, dir_fd=descriptor)
                except FileExistsError:
                    pass
                except OSError as error:
                    raise CaptureProblem("copy_failed reason=artifact_directory_create") from error
            child = _open_child_directory(
                descriptor,
                component,
                missing_reason=f"{component}_directory_missing",
                failure_reason=component.replace("-", "_") + "_directory",
            )
            os.close(descriptor)
            descriptor = child
        return descriptor
    except BaseException:
        os.close(descriptor)
        raise


def _ensure_capture_staging(build_root: Path) -> tuple[Path, int]:
    root, root_fd = _open_build_root(build_root)
    try:
        for name in (STAGING_DIRECTORY, CAPTURE_DIRECTORY):
            try:
                os.mkdir(name, 0o700, dir_fd=root_fd)
            except FileExistsError:
                pass
            except OSError as error:
                raise CaptureProblem("copy_failed reason=staging_directory_create") from error
            child = _open_child_directory(
                root_fd,
                name,
                missing_reason="staging_directory_missing",
                failure_reason="staging_directory",
            )
            os.close(root_fd)
            root_fd = child
        return root / STAGING_DIRECTORY / CAPTURE_DIRECTORY, root_fd
    except BaseException:
        os.close(root_fd)
        raise


def _open_test_logs(build_root: Path) -> int:
    return _open_directory_chain(build_root, ("work", "DerivedData", "Logs", "Test"))


def _scan_candidates(test_logs_fd: int) -> tuple[list[BundleCandidate], bool]:
    candidates: list[BundleCandidate] = []
    overflow = False
    try:
        with os.scandir(test_logs_fd) as entries:
            for entry in entries:
                if not entry.name.endswith(".xcresult"):
                    continue
                try:
                    info = os.stat(entry.name, dir_fd=test_logs_fd, follow_symlinks=False)
                except OSError as error:
                    raise CaptureProblem("inspection_failed reason=candidate_stat") from error
                if stat.S_ISLNK(info.st_mode):
                    kind = "symlink"
                elif stat.S_ISDIR(info.st_mode):
                    kind = "directory"
                else:
                    kind = "non_directory"
                if len(candidates) == MAX_CANDIDATES:
                    overflow = True
                    break
                candidates.append(
                    BundleCandidate(entry.name, kind, info.st_dev, info.st_ino)
                )
    except CaptureProblem:
        raise
    except OSError as error:
        raise CaptureProblem("inspection_failed reason=result_discovery") from error
    candidates.sort(key=lambda candidate: candidate.name)
    return candidates, overflow


def _read_enumeration_log(build_root: Path) -> tuple[str, bool]:
    descriptor = _open_directory_chain(build_root, ("evidence", "logs"))
    try:
        try:
            log_fd = os.open(
                "enumerate_Modules.log",
                os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
                dir_fd=descriptor,
            )
        except FileNotFoundError as error:
            raise CaptureProblem("missing reason=enumeration_log_missing") from error
        except OSError as error:
            raise CaptureProblem("inspection_failed reason=enumeration_log_open") from error
        try:
            info = os.fstat(log_fd)
            if not stat.S_ISREG(info.st_mode):
                raise CaptureProblem("inspection_failed reason=enumeration_log_not_regular")
            read_size = min(info.st_size, MAX_LOG_TAIL_BYTES)
            os.lseek(log_fd, info.st_size - read_size, os.SEEK_SET)
            chunks = bytearray()
            while len(chunks) < read_size:
                chunk = os.read(log_fd, min(65_536, read_size - len(chunks)))
                if not chunk:
                    break
                chunks.extend(chunk)
            if info.st_size > read_size:
                newline = chunks.find(b"\n")
                if newline >= 0:
                    del chunks[: newline + 1]
            return chunks.decode("utf-8", errors="replace"), info.st_size > read_size
        finally:
            os.close(log_fd)
    finally:
        os.close(descriptor)


def _reported_modules_name(build_root: Path) -> tuple[str | None, str | None]:
    root = Path(os.path.abspath(build_root))
    try:
        log_text, _truncated = _read_enumeration_log(root)
    except CaptureProblem as error:
        return None, str(error)

    test_logs = root / "work" / "DerivedData" / "Logs" / "Test"
    reported: set[str] = set()
    invalid_reason: str | None = None
    for line in log_text.splitlines():
        value = line.strip()
        if value.startswith("Result bundle written to:"):
            value = value.split(":", 1)[1].strip()
        if not value.startswith("/") or not value.endswith(".xcresult"):
            continue
        path = Path(value)
        if ".." in path.parts:
            invalid_reason = "inspection_failed reason=reported_path_parent_component"
            continue
        if not path.name.startswith(RESULT_BUNDLE_PREFIX):
            continue
        if path.parent != test_logs:
            invalid_reason = "inspection_failed reason=reported_path_outside_test_logs"
            continue
        reported.add(path.name)

    if len(reported) > 1:
        return None, f"inspection_failed reason=ambiguous_reported_paths count={len(reported)}"
    if not reported:
        return None, invalid_reason or "missing reason=modules_result_path_not_reported"
    return next(iter(reported)), None


def _entry_fingerprint(info: os.stat_result, kind: str) -> tuple[str, int, int, int, int, int]:
    device, inode, size, modified, changed = _fingerprint(info)
    return kind, device, inode, size, modified, changed


def _inventory_tree(
    directory_fd: int,
    prefix: str,
    max_files: int,
    max_bytes: int,
    manifest: dict,
    counts: list[int],
) -> None:
    try:
        names = sorted(os.listdir(directory_fd))
    except OSError as error:
        raise CaptureProblem("inspection_failed reason=file_inventory") from error
    manifest["children"][prefix] = names
    for name in names:
        try:
            info = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        except OSError as error:
            raise CaptureProblem("inspection_failed reason=file_inventory") from error
        relative = f"{prefix}/{name}" if prefix else name
        if stat.S_ISLNK(info.st_mode):
            raise CaptureProblem("inspection_failed reason=bundle_symlink")
        if stat.S_ISDIR(info.st_mode):
            fingerprint = _entry_fingerprint(info, "directory")
            manifest["entries"][relative] = fingerprint
            child_fd = _open_child_directory(
                directory_fd,
                name,
                expected_identity=(info.st_dev, info.st_ino),
                failure_reason="bundle_directory",
            )
            try:
                _inventory_tree(child_fd, relative, max_files, max_bytes, manifest, counts)
                if _entry_fingerprint(os.fstat(child_fd), "directory") != fingerprint:
                    raise CaptureProblem("inspection_failed reason=bundle_changed_during_inventory")
            finally:
                os.close(child_fd)
        elif stat.S_ISREG(info.st_mode):
            counts[0] += 1
            counts[1] += info.st_size
            if counts[0] > max_files:
                raise CaptureProblem(f"limit_reached reason=file_count_limit limit={max_files}")
            if counts[1] > max_bytes:
                raise CaptureProblem(f"oversized reason=over_size_limit limit_bytes={max_bytes}")
            manifest["entries"][relative] = _entry_fingerprint(info, "file")
        else:
            raise CaptureProblem("inspection_failed reason=non_regular_bundle_file")
    if sorted(os.listdir(directory_fd)) != names:
        raise CaptureProblem("inspection_failed reason=bundle_changed_during_inventory")


def _inventory_bundle_fd(
    bundle_fd: int,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
) -> tuple[int, int, dict]:
    previous_handler = None
    counts = [0, 0]
    manifest = {"entries": {}, "children": {}}
    try:
        try:
            previous_handler = signal.signal(signal.SIGALRM, _alarm_handler)
            signal.alarm(INVENTORY_TIMEOUT_SECONDS)
        except (AttributeError, OSError, ValueError) as error:
            raise CaptureProblem("inspection_failed reason=inventory_timeout_unavailable") from error
        _inventory_tree(bundle_fd, "", max_files, max_bytes, manifest, counts)
    except TimeoutError as error:
        raise CaptureProblem(
            f"inspection_failed reason=file_inventory_timeout seconds={INVENTORY_TIMEOUT_SECONDS}"
        ) from error
    finally:
        if previous_handler is not None:
            try:
                signal.alarm(0)
                signal.signal(signal.SIGALRM, previous_handler)
            except (AttributeError, OSError, ValueError):
                pass
    return counts[0], counts[1], manifest


def inventory_bundle(
    bundle: Path,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
) -> tuple[int, int]:
    """Count regular bundle files without following symbolic links."""
    path = Path(os.path.abspath(bundle))
    parent = path.parent.resolve(strict=True)
    try:
        parent_fd = os.open(parent, _directory_flags())
    except OSError as error:
        raise CaptureProblem("inspection_failed reason=file_inventory") from error
    try:
        bundle_fd = _open_child_directory(
            parent_fd, path.name, missing_reason="no_xcresult_bundle", failure_reason="bundle"
        )
        try:
            files, total_bytes, _manifest = _inventory_bundle_fd(bundle_fd, max_files, max_bytes)
            return files, total_bytes
        finally:
            os.close(bundle_fd)
    finally:
        os.close(parent_fd)


def _copy_tree(
    source_fd: int,
    destination_fd: int,
    prefix: str,
    manifest: dict,
    counts: list[int],
    max_files: int,
    max_bytes: int,
    deadline: float,
) -> None:
    if time.monotonic() > deadline:
        raise TimeoutError
    try:
        names = sorted(os.listdir(source_fd))
    except OSError as error:
        raise CaptureProblem("copy_failed reason=source_read") from error
    if names != manifest["children"].get(prefix):
        raise CaptureProblem("inspection_failed reason=bundle_changed_before_copy")
    for name in names:
        if time.monotonic() > deadline:
            raise TimeoutError
        relative = f"{prefix}/{name}" if prefix else name
        expected = manifest["entries"].get(relative)
        if expected is None:
            raise CaptureProblem("inspection_failed reason=bundle_manifest_mismatch")
        try:
            info = os.stat(name, dir_fd=source_fd, follow_symlinks=False)
        except OSError as error:
            raise CaptureProblem("inspection_failed reason=bundle_changed_before_copy") from error
        kind = "directory" if stat.S_ISDIR(info.st_mode) else "file" if stat.S_ISREG(info.st_mode) else "other"
        if kind == "other" or _entry_fingerprint(info, kind) != expected:
            raise CaptureProblem("inspection_failed reason=bundle_changed_before_copy")
        if kind == "directory":
            source_child = _open_child_directory(
                source_fd,
                name,
                expected_identity=(info.st_dev, info.st_ino),
                failure_reason="bundle_directory",
            )
            try:
                os.mkdir(name, 0o700, dir_fd=destination_fd)
                destination_child = os.open(name, _directory_flags(), dir_fd=destination_fd)
                try:
                    _copy_tree(
                        source_child,
                        destination_child,
                        relative,
                        manifest,
                        counts,
                        max_files,
                        max_bytes,
                        deadline,
                    )
                finally:
                    os.close(destination_child)
                if _entry_fingerprint(os.fstat(source_child), "directory") != expected:
                    raise CaptureProblem("inspection_failed reason=bundle_changed_during_copy")
            finally:
                os.close(source_child)
            continue

        try:
            source_file = os.open(
                name,
                os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
                dir_fd=source_fd,
            )
        except OSError as error:
            raise CaptureProblem("inspection_failed reason=bundle_file_open") from error
        destination_file = None
        try:
            before = os.fstat(source_file)
            if _entry_fingerprint(before, "file") != expected:
                raise CaptureProblem("inspection_failed reason=bundle_file_replaced")
            destination_file = os.open(
                name,
                os.O_WRONLY
                | os.O_CREAT
                | os.O_EXCL
                | getattr(os, "O_NOFOLLOW", 0),
                0o600,
                dir_fd=destination_fd,
            )
            copied = 0
            while True:
                if time.monotonic() > deadline:
                    raise TimeoutError
                chunk = os.read(source_file, 65_536)
                if not chunk:
                    break
                copied += len(chunk)
                counts[1] += len(chunk)
                if counts[1] > max_bytes:
                    raise CaptureProblem(f"oversized reason=over_size_limit limit_bytes={max_bytes}")
                view = memoryview(chunk)
                while view:
                    written = os.write(destination_file, view)
                    view = view[written:]
            after = os.fstat(source_file)
            if copied != before.st_size or _entry_fingerprint(after, "file") != expected:
                raise CaptureProblem("inspection_failed reason=bundle_changed_during_copy")
            counts[0] += 1
            if counts[0] > max_files:
                raise CaptureProblem(f"limit_reached reason=file_count_limit limit={max_files}")
        except OSError as error:
            raise CaptureProblem("copy_failed reason=file_copy") from error
        finally:
            if destination_file is not None:
                os.close(destination_file)
            os.close(source_file)
    if sorted(os.listdir(source_fd)) != names:
        raise CaptureProblem("inspection_failed reason=bundle_changed_during_copy")


def _copy_bundle_fd(
    source_fd: int,
    stage_fd: int,
    temporary_name: str,
    max_files: int,
    max_bytes: int,
    copy_timeout_seconds: int,
) -> tuple[int, int]:
    inventory_files, inventory_bytes, manifest = _inventory_bundle_fd(
        source_fd, max_files, max_bytes
    )
    try:
        os.mkdir(temporary_name, 0o700, dir_fd=stage_fd)
        temporary_fd = os.open(temporary_name, _directory_flags(), dir_fd=stage_fd)
    except OSError as error:
        raise CaptureProblem("copy_failed reason=staging_directory_create") from error
    previous_handler = None
    counts = [0, 0]
    deadline = time.monotonic() + copy_timeout_seconds
    try:
        try:
            previous_handler = signal.signal(signal.SIGALRM, _alarm_handler)
            signal.alarm(copy_timeout_seconds)
        except (AttributeError, OSError, ValueError) as error:
            raise CaptureProblem("copy_failed reason=copy_timeout_unavailable") from error
        os.mkdir(STAGED_BUNDLE, 0o700, dir_fd=temporary_fd)
        destination_fd = os.open(STAGED_BUNDLE, _directory_flags(), dir_fd=temporary_fd)
        try:
            _copy_tree(
                source_fd,
                destination_fd,
                "",
                manifest,
                counts,
                max_files,
                max_bytes,
                deadline,
            )
        finally:
            os.close(destination_fd)
        if (counts[0], counts[1]) != (inventory_files, inventory_bytes):
            raise CaptureProblem("inspection_failed reason=copy_verification")
        os.rename(
            STAGED_BUNDLE,
            STAGED_BUNDLE,
            src_dir_fd=temporary_fd,
            dst_dir_fd=stage_fd,
        )
    except TimeoutError as error:
        raise CaptureProblem(f"copy_timed_out seconds={copy_timeout_seconds}") from error
    except CaptureProblem:
        raise
    except OSError as error:
        raise CaptureProblem("copy_failed reason=copy_verification") from error
    finally:
        if previous_handler is not None:
            try:
                signal.alarm(0)
                signal.signal(signal.SIGALRM, previous_handler)
            except (AttributeError, OSError, ValueError):
                pass
        os.close(temporary_fd)
        try:
            os.rmdir(temporary_name, dir_fd=stage_fd)
        except OSError:
            pass
    return counts[0], counts[1]


def _stop_summary_process(process: subprocess.Popen[bytes]) -> None:
    if process.poll() is None:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except OSError:
            process.kill()
    try:
        process.wait(timeout=1)
    except subprocess.TimeoutExpired:
        pass


def _summary_title(bundle: Path) -> tuple[str | None, bool]:
    process: subprocess.Popen[bytes] | None = None
    output = bytearray()
    try:
        process = subprocess.Popen(
            [
                "xcrun",
                "xcresulttool",
                "get",
                "test-results",
                "summary",
                "--path",
                str(bundle),
                "--format",
                "json",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        assert process.stdout is not None
        deadline = time.monotonic() + SUMMARY_TIMEOUT_SECONDS
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                _stop_summary_process(process)
                return None, False
            ready, _, _ = select.select([process.stdout], [], [], remaining)
            if not ready:
                _stop_summary_process(process)
                return None, False
            read_limit = min(8192, SUMMARY_LIMIT_BYTES + 1 - len(output))
            chunk = os.read(process.stdout.fileno(), read_limit)
            if not chunk:
                break
            output.extend(chunk)
            if len(output) > SUMMARY_LIMIT_BYTES:
                _stop_summary_process(process)
                return None, False
        if process.wait(timeout=max(0.01, deadline - time.monotonic())) != 0:
            return None, False
    except (OSError, ValueError, subprocess.TimeoutExpired):
        if process is not None:
            _stop_summary_process(process)
        return None, False
    finally:
        if process is not None and process.stdout is not None:
            process.stdout.close()
    try:
        title = json.loads(output).get("title")
    except (json.JSONDecodeError, AttributeError):
        return None, False
    return (title if isinstance(title, str) else None), True


def _candidate_record(candidate: BundleCandidate) -> dict:
    return {
        "name": candidate.name,
        "selection": "not_selected",
        "summary_title": None,
        "query_failure": "not_queried_exact_log_path_only",
        "capture_status": "not_attempted",
    }


def _write_capture_record(stage_fd: int, record: dict) -> None:
    encoded = json.dumps(record, sort_keys=True, separators=(",", ":")).encode("utf-8")
    if len(encoded) > MAX_CAPTURE_RECORD_BYTES:
        raise CaptureProblem("inspection_failed reason=capture_record_limit")
    temporary = "capture-record.tmp"
    try:
        descriptor = os.open(
            temporary,
            os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0),
            0o600,
            dir_fd=stage_fd,
        )
        try:
            view = memoryview(encoded)
            while view:
                written = os.write(descriptor, view)
                view = view[written:]
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
        os.rename(temporary, CAPTURE_RECORD, src_dir_fd=stage_fd, dst_dir_fd=stage_fd)
    except OSError as error:
        try:
            os.unlink(temporary, dir_fd=stage_fd)
        except OSError:
            pass
        raise CaptureProblem("inspection_failed reason=capture_record_write") from error


def _capture_to_staging(
    build_root: Path,
    *,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
    copy_timeout_seconds: int = MAX_COPY_SECONDS,
    gate_exit_code: int | None = None,
) -> dict:
    stage_path, stage_fd = _ensure_capture_staging(build_root)
    candidates: list[BundleCandidate] = []
    candidate_records: list[dict] = []
    record: dict = {
        "state": "failed",
        "reason": "inspection_failed reason=capture_not_started",
        "selection": "none",
        "files": 0,
        "bytes": 0,
        "gate_exit_code": gate_exit_code,
        "candidates": candidate_records,
    }
    try:
        test_logs_fd = _open_test_logs(build_root)
        try:
            candidates, overflow = _scan_candidates(test_logs_fd)
        finally:
            os.close(test_logs_fd)
        candidate_records.extend(_candidate_record(candidate) for candidate in candidates)
        if overflow:
            raise CaptureProblem(f"limit_reached reason=candidate_count limit={MAX_CANDIDATES}")

        selected_name, path_error = _reported_modules_name(build_root)
        if path_error is not None:
            raise CaptureProblem(path_error.removeprefix("enumeration_xcresult_capture="))
        assert selected_name is not None
        selected = next((item for item in candidates if item.name == selected_name), None)
        if selected is None:
            raise CaptureProblem("missing reason=reported_bundle_not_available")
        selected_index = candidates.index(selected)
        candidate_records[selected_index]["selection"] = "selected_by_enumeration_log"
        candidate_records[selected_index]["query_failure"] = "not_queried_capture_pending"
        record["selection"] = "reported_enumeration_log_path"

        if selected.kind == "symlink":
            candidate_records[selected_index]["capture_status"] = "rejected_symlink"
            candidate_records[selected_index]["query_failure"] = "not_queried_unsafe_candidate"
            raise CaptureProblem("inspection_failed reason=reported_bundle_symlink")
        if selected.kind != "directory":
            candidate_records[selected_index]["capture_status"] = "rejected_non_directory"
            raise CaptureProblem("inspection_failed reason=reported_bundle_not_directory")

        test_logs_fd = _open_test_logs(build_root)
        try:
            source_fd = _open_child_directory(
                test_logs_fd,
                selected.name,
                expected_identity=(selected.device, selected.inode),
                missing_reason="reported_bundle_not_available",
                failure_reason="reported_bundle",
            )
        finally:
            os.close(test_logs_fd)
        try:
            temporary_name = f"enumeration-{os.getpid()}-{time.monotonic_ns()}"
            files, total_bytes = _copy_bundle_fd(
                source_fd,
                stage_fd,
                temporary_name,
                max_files,
                max_bytes,
                copy_timeout_seconds,
            )
        except CaptureProblem as error:
            candidate_records[selected_index]["capture_status"] = str(error)
            candidate_records[selected_index]["query_failure"] = "not_queried_capture_failed"
            raise
        finally:
            os.close(source_fd)

        staged_bundle = stage_path / STAGED_BUNDLE
        title, inspected = _summary_title(staged_bundle)
        if inspected and title is not None:
            candidate_records[selected_index]["summary_title"] = title[:128]
            candidate_records[selected_index]["query_failure"] = None
        else:
            candidate_records[selected_index]["query_failure"] = "summary_query_failed"
        candidate_records[selected_index]["capture_status"] = "staged"
        record.update(
            state="captured",
            reason=None,
            files=files,
            bytes=total_bytes,
            selection="reported_enumeration_log_path",
            copy_timeout_seconds=copy_timeout_seconds,
        )
        if gate_exit_code is not None:
            record["gate_exit_code"] = gate_exit_code
    except CaptureProblem as error:
        record.update(state="failed", reason=str(error))
    except OSError as error:
        record.update(state="failed", reason="inspection_failed reason=unexpected_filesystem_error")
    finally:
        try:
            _write_capture_record(stage_fd, record)
        finally:
            os.close(stage_fd)
    return record


def _safe_status_value(value: object, limit: int = 96) -> str:
    if not isinstance(value, str):
        return "unknown"
    raw = value.encode("utf-8", errors="replace")[:limit]
    return quote_from_bytes(raw, safe="-._")


def _candidate_status_line(candidate: dict, final_state: str | None = None) -> str:
    name = _safe_status_value(candidate.get("name", "unknown"))
    selection = _safe_status_value(candidate.get("selection", "unknown"))
    summary_title = candidate.get("summary_title")
    query_failure = candidate.get("query_failure")
    if isinstance(summary_title, str):
        summary = f"summary_title={_safe_status_value(summary_title, 128)}"
    else:
        summary = f"summary_query_failure={_safe_status_value(query_failure or 'unknown')}"
    capture_status = final_state or str(candidate.get("capture_status", "unknown"))
    return (
        f"enumeration_candidate name={name} selection={selection} {summary} "
        f"capture={_safe_status_value(capture_status)}"
    )


def _open_enumeration_directory(build_root: Path) -> int:
    descriptor = _open_directory_chain(
        build_root, ("evidence", "hosted-simulator-diagnostics", "enumeration"), create=True
    )
    return descriptor


def append_status(build_root: Path, outcome: str) -> bool:
    descriptor = None
    try:
        descriptor = _open_directory_chain(
            build_root, ("evidence", "hosted-simulator-diagnostics"), create=True
        )
        flags = os.O_WRONLY | os.O_APPEND | os.O_CREAT | getattr(os, "O_NOFOLLOW", 0)
        status_fd = os.open("collection-status.txt", flags, 0o600, dir_fd=descriptor)
        try:
            if not stat.S_ISREG(os.fstat(status_fd).st_mode):
                raise OSError("diagnostic status is not a regular file")
            line = outcome.replace("\n", " ").replace("\r", " ")[:1024]
            os.write(status_fd, (line + "\n").encode("utf-8"))
        finally:
            os.close(status_fd)
    except (CaptureProblem, OSError, ValueError):
        print("::error::Could not safely record enumeration result capture status")
        return False
    finally:
        if descriptor is not None:
            os.close(descriptor)
    return True


def _read_capture_record(stage_fd: int) -> dict:
    try:
        descriptor = os.open(
            CAPTURE_RECORD,
            os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
            dir_fd=stage_fd,
        )
        try:
            info = os.fstat(descriptor)
            if not stat.S_ISREG(info.st_mode) or info.st_size > MAX_CAPTURE_RECORD_BYTES:
                raise CaptureProblem("inspection_failed reason=capture_record_invalid")
            chunks = bytearray()
            while len(chunks) <= MAX_CAPTURE_RECORD_BYTES:
                chunk = os.read(descriptor, MAX_CAPTURE_RECORD_BYTES + 1 - len(chunks))
                if not chunk:
                    break
                chunks.extend(chunk)
            if len(chunks) > MAX_CAPTURE_RECORD_BYTES:
                raise CaptureProblem("inspection_failed reason=capture_record_limit")
            record = json.loads(chunks)
        finally:
            os.close(descriptor)
    except CaptureProblem:
        raise
    except (OSError, json.JSONDecodeError) as error:
        raise CaptureProblem("inspection_failed reason=capture_record_missing_or_invalid") from error
    if not isinstance(record, dict) or record.get("state") not in {"captured", "failed"}:
        raise CaptureProblem("inspection_failed reason=capture_record_invalid")
    if not isinstance(record.get("candidates", []), list):
        raise CaptureProblem("inspection_failed reason=capture_record_invalid")
    return record


def publish_staged_capture(build_root: Path) -> str:
    stage_fd = None
    destination_fd = None
    record: dict = {
        "state": "failed",
        "reason": "missing reason=observer_capture_record_missing",
        "candidates": [],
    }
    try:
        _root, root_fd = _open_build_root(build_root)
        try:
            try:
                staging_fd = _open_child_directory(root_fd, STAGING_DIRECTORY)
            finally:
                os.close(root_fd)
            try:
                stage_fd = _open_child_directory(staging_fd, CAPTURE_DIRECTORY)
            finally:
                os.close(staging_fd)
            record = _read_capture_record(stage_fd)
        except CaptureProblem as error:
            record["reason"] = str(error)

        if record.get("state") == "captured":
            try:
                destination_fd = _open_enumeration_directory(build_root)
                staged_info = os.stat(STAGED_BUNDLE, dir_fd=stage_fd, follow_symlinks=False)
                if not stat.S_ISDIR(staged_info.st_mode):
                    raise CaptureProblem("copy_failed reason=staged_bundle_not_directory")
                staged_fd = _open_child_directory(stage_fd, STAGED_BUNDLE)
                try:
                    files, total_bytes, _manifest = _inventory_bundle_fd(
                        staged_fd, MAX_BUNDLE_FILES, MAX_BUNDLE_BYTES
                    )
                finally:
                    os.close(staged_fd)
                if (files, total_bytes) != (record.get("files"), record.get("bytes")):
                    raise CaptureProblem("copy_failed reason=staged_bundle_verification")
                try:
                    os.stat(STAGED_BUNDLE, dir_fd=destination_fd, follow_symlinks=False)
                except FileNotFoundError:
                    pass
                else:
                    raise CaptureProblem("copy_failed reason=artifact_limit_reached max_artifacts=1")
                os.rename(
                    STAGED_BUNDLE,
                    STAGED_BUNDLE,
                    src_dir_fd=stage_fd,
                    dst_dir_fd=destination_fd,
                )
                outcome = status_line(
                    "captured",
                    selection="reported_enumeration_log_path",
                    files=files,
                    bytes=total_bytes,
                    max_files=MAX_BUNDLE_FILES,
                    max_bytes=MAX_BUNDLE_BYTES,
                    max_copy_seconds=record.get("copy_timeout_seconds", MAX_COPY_SECONDS),
                    max_artifacts=1,
                    gate_exit_code=record.get("gate_exit_code", "unknown"),
                )
                selected_state = "captured"
            except (CaptureProblem, OSError) as error:
                outcome = f"enumeration_xcresult_capture={error}"
                selected_state = "publish_failed"
        else:
            outcome = f"enumeration_xcresult_capture={record.get('reason', 'inspection_failed reason=capture_record_invalid')}"
            selected_state = None
    except (CaptureProblem, OSError, ValueError) as error:
        outcome = f"enumeration_xcresult_capture={error}"
        selected_state = "publish_failed"
    finally:
        if stage_fd is not None:
            os.close(stage_fd)
        if destination_fd is not None:
            os.close(destination_fd)

    status_ok = True
    for candidate in record.get("candidates", [])[:MAX_CANDIDATES]:
        if isinstance(candidate, dict):
            final_state = selected_state if candidate.get("selection") == "selected_by_enumeration_log" else None
            status_ok = append_status(build_root, _candidate_status_line(candidate, final_state)) and status_ok
    status_ok = append_status(build_root, outcome) and status_ok
    if not status_ok:
        return "enumeration_xcresult_capture=inspection_failed reason=status_write"
    return outcome


def capture_enumeration_xcresult(
    build_root: Path,
    *,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
    copy_timeout_seconds: int = MAX_COPY_SECONDS,
) -> str:
    """Select from the logged Modules path, stage it safely, and publish it."""
    gate_exit_code = None
    try:
        _gate_state, gate_exit_code = _read_gate_exit(build_root)
    except CaptureProblem:
        pass
    try:
        _capture_to_staging(
            build_root,
            max_files=max_files,
            max_bytes=max_bytes,
            copy_timeout_seconds=copy_timeout_seconds,
            gate_exit_code=gate_exit_code,
        )
    except CaptureProblem as error:
        if not append_status(build_root, f"enumeration_xcresult_capture={error}"):
            return "enumeration_xcresult_capture=inspection_failed reason=status_write"
        return f"enumeration_xcresult_capture={error}"
    return publish_staged_capture(build_root)


def _read_gate_exit(
    build_root: Path,
    *,
    retry_seconds: float = GATE_MARKER_READ_RETRY_SECONDS,
) -> tuple[GateMarkerState, int | None]:
    """Read a complete gate marker, allowing briefly for its in-place rewrite."""
    retry_seconds = min(
        GATE_MARKER_READ_RETRY_SECONDS, max(0.0, retry_seconds)
    )
    deadline = time.monotonic() + retry_seconds
    while True:
        try:
            logs_fd = _open_directory_chain(build_root, ("evidence", "logs"))
        except CaptureProblem as error:
            if str(error).startswith("missing reason="):
                return "not_run", None
            raise
        try:
            try:
                descriptor = os.open(
                    "enumerate_Modules.exit",
                    os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
                    dir_fd=logs_fd,
                )
            except FileNotFoundError:
                return "not_run", None
            except OSError as error:
                raise CaptureProblem(
                    "inspection_failed reason=enumeration_gate_marker_open"
                ) from error
            try:
                info = os.fstat(descriptor)
                if (
                    not stat.S_ISREG(info.st_mode)
                    or info.st_size > GATE_MARKER_MAX_BYTES
                ):
                    raise CaptureProblem(
                        "inspection_failed reason=enumeration_gate_marker_invalid"
                    )
                raw_value = os.read(descriptor, GATE_MARKER_MAX_BYTES + 1)
            finally:
                os.close(descriptor)
        finally:
            os.close(logs_fd)

        if raw_value == b"not_run\n":
            return "not_run", None
        if raw_value == b"in_progress\n":
            return "in_progress", None
        if raw_value.endswith(b"\n"):
            digits = raw_value[:-1]
            if digits.isdigit() and (digits == b"0" or not digits.startswith(b"0")):
                exit_code = int(digits)
                if exit_code <= 255:
                    return "completed", exit_code

        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise CaptureProblem(
                "inspection_failed reason=enumeration_gate_marker_invalid"
            )
        time.sleep(min(GATE_MARKER_READ_RETRY_INTERVAL_SECONDS, remaining))


def _process_is_running(process_id: int) -> bool:
    try:
        os.kill(process_id, 0)
        return True
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    except OSError:
        return False


def _wait_for_modules_gate(
    build_root: Path,
    verifier_pid: int,
    timeout_seconds: int,
    poll_seconds: float = OBSERVER_POLL_SECONDS,
) -> int | None:
    if verifier_pid <= 1 or timeout_seconds <= 0:
        raise CaptureProblem("inspection_failed reason=observer_arguments_invalid")
    deadline = time.monotonic() + timeout_seconds
    while time.monotonic() < deadline:
        state, exit_code = _read_gate_exit(
            build_root,
            retry_seconds=min(
                GATE_MARKER_READ_RETRY_SECONDS,
                max(0.0, deadline - time.monotonic()),
            ),
        )
        if state == "completed" and exit_code is not None:
            return exit_code
        if not _process_is_running(verifier_pid):
            if state == "in_progress":
                raise CaptureProblem("inspection_failed reason=enumerate_Modules_gate_incomplete")
            return None
        time.sleep(min(poll_seconds, max(0.0, deadline - time.monotonic())))
    raise CaptureProblem(f"inspection_failed reason=enumeration_observer_timeout seconds={timeout_seconds}")


def observe_enumeration_result(
    build_root: Path,
    verifier_pid: int,
    *,
    timeout_seconds: int = MAX_OBSERVER_SECONDS,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
    copy_timeout_seconds: int = MAX_COPY_SECONDS,
    poll_seconds: float = OBSERVER_POLL_SECONDS,
) -> str:
    """Wait for the gate marker, then copy its logged result before later gates run."""
    try:
        gate_exit_code = _wait_for_modules_gate(
            build_root, verifier_pid, timeout_seconds, poll_seconds
        )
        if gate_exit_code is None:
            raise CaptureProblem("missing reason=enumerate_Modules_gate_not_reached")
        record = _capture_to_staging(
            build_root,
            max_files=max_files,
            max_bytes=max_bytes,
            copy_timeout_seconds=copy_timeout_seconds,
            gate_exit_code=gate_exit_code,
        )
    except CaptureProblem as error:
        try:
            stage_path, stage_fd = _ensure_capture_staging(build_root)
            del stage_path
            try:
                candidates: list[BundleCandidate] = []
                try:
                    logs_fd = _open_test_logs(build_root)
                    try:
                        candidates, _overflow = _scan_candidates(logs_fd)
                    finally:
                        os.close(logs_fd)
                except CaptureProblem:
                    pass
                record = {
                    "state": "failed",
                    "reason": str(error),
                    "selection": "none",
                    "files": 0,
                    "bytes": 0,
                    "gate_exit_code": None,
                    "candidates": [_candidate_record(candidate) for candidate in candidates],
                }
                _write_capture_record(stage_fd, record)
            finally:
                os.close(stage_fd)
        except CaptureProblem as stage_error:
            print(f"::error::Could not record enumeration observer result: {stage_error}")
            return status_line("inspection_failed", reason="observer_record_unavailable")
    outcome = (
        status_line("staged", selection=record.get("selection", "none"), gate_exit_code=record.get("gate_exit_code", "unknown"))
        if record.get("state") == "captured"
        else f"enumeration_xcresult_capture={record.get('reason', 'inspection_failed reason=capture_record_invalid')}"
    )
    return outcome


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("build_root", type=Path)
    parser.add_argument("--max-files", type=int, default=MAX_BUNDLE_FILES)
    parser.add_argument("--max-bytes", type=int, default=MAX_BUNDLE_BYTES)
    parser.add_argument("--copy-timeout-seconds", type=int, default=MAX_COPY_SECONDS)
    parser.add_argument("--watch-verifier-pid", type=int)
    parser.add_argument("--wait-timeout-seconds", type=int, default=MAX_OBSERVER_SECONDS)
    parser.add_argument("--publish-staged", action="store_true")
    arguments = parser.parse_args()
    try:
        if arguments.publish_staged:
            outcome = publish_staged_capture(arguments.build_root)
        elif arguments.watch_verifier_pid is not None:
            outcome = observe_enumeration_result(
                arguments.build_root,
                arguments.watch_verifier_pid,
                timeout_seconds=arguments.wait_timeout_seconds,
                max_files=arguments.max_files,
                max_bytes=arguments.max_bytes,
                copy_timeout_seconds=arguments.copy_timeout_seconds,
            )
        else:
            outcome = capture_enumeration_xcresult(
                arguments.build_root,
                max_files=arguments.max_files,
                max_bytes=arguments.max_bytes,
                copy_timeout_seconds=arguments.copy_timeout_seconds,
            )
    except CaptureProblem as error:
        outcome = f"enumeration_xcresult_capture={error}"
        if not append_status(arguments.build_root, outcome):
            return 1
    except Exception as error:
        outcome = status_line("inspection_failed", reason=f"unexpected_{type(error).__name__}")
        print(f"::error::{outcome}")
        traceback.print_tb(error.__traceback__)
        return 1
    if not outcome.startswith("enumeration_xcresult_capture=captured") and not outcome.startswith(
        "enumeration_xcresult_capture=staged"
    ):
        if "::warning::" not in outcome:
            print(f"::warning::{outcome}")
    if arguments.watch_verifier_pid is not None and "observer_record_unavailable" in outcome:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
