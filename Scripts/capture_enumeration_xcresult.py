#!/usr/bin/env python3
"""Preserve this run's Modules enumeration result from isolated DerivedData.

The CI workflow runs this after canonical verification. Capture outcomes go to
the hosted diagnostic status file; this command does not set the canonical gate.
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
from pathlib import Path


MAX_CANDIDATES = 8
SUMMARY_TIMEOUT_SECONDS = 4
SUMMARY_LIMIT_BYTES = 65_536
INVENTORY_TIMEOUT_SECONDS = 5
MAX_BUNDLE_FILES = 10_000
MAX_BUNDLE_BYTES = 512 * 1024 * 1024
MAX_COPY_SECONDS = 45


class CaptureProblem(Exception):
    """A bounded capture could not identify or retain its result bundle."""


def status_line(state: str, **details: object) -> str:
    suffix = " ".join(f"{key}={value}" for key, value in details.items())
    return f"enumeration_xcresult_capture={state}" + (f" {suffix}" if suffix else "")


def _alarm_handler(_signum: int, _frame: object) -> None:
    raise TimeoutError


def _raise_walk_error(error: OSError) -> None:
    raise error


def inventory_bundle(
    bundle: Path,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
) -> tuple[int, int]:
    """Count regular files and bytes without following links outside a bundle."""
    previous_handler = None
    file_count = total_bytes = 0
    try:
        try:
            previous_handler = signal.signal(signal.SIGALRM, _alarm_handler)
            signal.alarm(INVENTORY_TIMEOUT_SECONDS)
        except (AttributeError, OSError, ValueError) as error:
            raise CaptureProblem(
                "inspection_failed reason=inventory_timeout_unavailable"
            ) from error
        for directory, subdirectories, filenames in os.walk(
            bundle, followlinks=False, onerror=_raise_walk_error
        ):
            for name in subdirectories:
                if stat.S_ISLNK(os.lstat(os.path.join(directory, name)).st_mode):
                    raise CaptureProblem("inspection_failed reason=bundle_symlink")
            for name in filenames:
                info = os.lstat(os.path.join(directory, name))
                if not stat.S_ISREG(info.st_mode):
                    raise CaptureProblem("inspection_failed reason=non_regular_bundle_file")
                file_count += 1
                total_bytes += info.st_size
                if file_count > max_files:
                    raise CaptureProblem(
                        f"limit_reached reason=file_count_limit limit={max_files}"
                    )
                if total_bytes > max_bytes:
                    raise CaptureProblem(
                        f"oversized reason=over_size_limit limit_bytes={max_bytes}"
                    )
    except TimeoutError as error:
        raise CaptureProblem(
            f"inspection_failed reason=file_inventory_timeout seconds={INVENTORY_TIMEOUT_SECONDS}"
        ) from error
    except OSError as error:
        raise CaptureProblem("inspection_failed reason=file_inventory") from error
    finally:
        if previous_handler is not None:
            try:
                signal.alarm(0)
                signal.signal(signal.SIGALRM, previous_handler)
            except (AttributeError, OSError, ValueError):
                pass
    return file_count, total_bytes


def discover_bundles(build_root: Path) -> list[Path]:
    """Find only direct result bundles in this run's DerivedData test logs."""
    build_root = build_root.resolve()
    work = build_root / "work"
    derived_data = work / "DerivedData"
    logs = derived_data / "Logs"
    test_logs = derived_data / "Logs" / "Test"
    for directory in (work, derived_data, logs, test_logs):
        try:
            info = os.lstat(directory)
        except FileNotFoundError as error:
            raise CaptureProblem("missing reason=test_log_directory_missing") from error
        except OSError as error:
            raise CaptureProblem("inspection_failed reason=test_log_directory") from error
        if stat.S_ISLNK(info.st_mode):
            raise CaptureProblem("inspection_failed reason=test_log_directory_symlink")
        if not stat.S_ISDIR(info.st_mode):
            raise CaptureProblem("inspection_failed reason=test_log_path_not_directory")
    try:
        work.resolve(strict=True).relative_to(build_root)
        derived_data.resolve(strict=True).relative_to(build_root)
        logs.resolve(strict=True).relative_to(derived_data.resolve(strict=True))
        test_logs.resolve(strict=True).relative_to(derived_data.resolve(strict=True))
        bundles: list[Path] = []
        with os.scandir(test_logs) as entries:
            for entry in entries:
                if not entry.name.endswith(".xcresult"):
                    continue
                if entry.is_symlink():
                    raise CaptureProblem("inspection_failed reason=bundle_symlink")
                if entry.is_dir(follow_symlinks=False):
                    bundles.append(Path(entry.path))
                    if len(bundles) > MAX_CANDIDATES:
                        raise CaptureProblem(
                            f"limit_reached reason=candidate_count limit={MAX_CANDIDATES}"
                        )
    except CaptureProblem:
        raise
    except (OSError, ValueError) as error:
        raise CaptureProblem("inspection_failed reason=result_discovery") from error
    if not bundles:
        raise CaptureProblem("missing reason=no_xcresult_bundle")
    return sorted(bundles)


def _first_failure_gate(build_root: Path) -> str | None:
    manifest = build_root / "evidence" / "manifest.json"
    if manifest.is_symlink():
        return None
    try:
        first_failure = json.loads(manifest.read_text(encoding="utf-8")).get("firstFailure")
    except (OSError, json.JSONDecodeError):
        return None
    gate = first_failure.get("gate") if isinstance(first_failure, dict) else None
    return gate if isinstance(gate, str) else None


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


def select_modules_bundle(
    bundles: list[Path],
    build_root: Path,
    max_files: int,
    max_bytes: int,
) -> tuple[Path, str, tuple[int, int], int]:
    matches: list[Path] = []
    inventories: dict[Path, tuple[int, int]] = {}
    failed_queries = 0
    over_limit: list[tuple[Path, str]] = []
    for bundle in bundles:
        try:
            inventories[bundle] = inventory_bundle(bundle, max_files, max_bytes)
        except CaptureProblem as error:
            if str(error).startswith(("limit_reached", "oversized")):
                over_limit.append((bundle, str(error)))
                continue
            raise
        title, inspected = _summary_title(bundle)
        if title == "Test - Modules":
            matches.append(bundle)
        elif not inspected:
            failed_queries += 1

    if len(matches) == 1:
        return matches[0], "summary_title", inventories[matches[0]], len(over_limit)
    if len(matches) > 1:
        raise CaptureProblem(
            f"inspection_failed reason=ambiguous_modules_bundles candidates={len(bundles)}"
        )
    if len(bundles) == 1 and over_limit:
        raise CaptureProblem(over_limit[0][1])
    if len(bundles) == 1 and _first_failure_gate(build_root) == "enumerate_Modules":
        bundle = bundles[0]
        if bundle in inventories and failed_queries:
            return bundle, "manifest_failure_gate", inventories[bundle], 0
        if over_limit:
            raise CaptureProblem(over_limit[0][1])
    if over_limit:
        raise CaptureProblem(
            f"limit_reached reason=uninspected_candidate_bundles count={len(over_limit)}"
        )
    raise CaptureProblem(
        f"missing reason=modules_bundle_not_identified candidates={len(bundles)} "
        f"summary_queries_failed={failed_queries}"
    )


def prepare_diagnostics(build_root: Path) -> Path:
    evidence = build_root / "evidence"
    diagnostics = evidence / "hosted-simulator-diagnostics"
    if evidence.is_symlink() or diagnostics.is_symlink():
        raise CaptureProblem("copy_failed reason=artifact_destination_isolation")
    try:
        diagnostics.mkdir(parents=True, exist_ok=True)
        diagnostics.resolve(strict=True).relative_to(build_root)
    except (OSError, ValueError) as error:
        raise CaptureProblem("copy_failed reason=artifact_destination_isolation") from error
    return diagnostics


def open_enumeration_directory(build_root: Path) -> int:
    """Open the artifact directory through no-follow handles for every parent."""
    directory_flags = getattr(os, "O_DIRECTORY", 0) | getattr(os, "O_NOFOLLOW", 0)
    if not directory_flags or not hasattr(os, "O_DIRECTORY") or not hasattr(os, "O_NOFOLLOW"):
        raise CaptureProblem("copy_failed reason=artifact_directory_isolation")
    root_fd = evidence_fd = diagnostics_fd = None
    try:
        root_fd = os.open(build_root, os.O_RDONLY | directory_flags)
        evidence_fd = os.open("evidence", os.O_RDONLY | directory_flags, dir_fd=root_fd)
        diagnostics_fd = os.open(
            "hosted-simulator-diagnostics", os.O_RDONLY | directory_flags, dir_fd=evidence_fd
        )
        try:
            os.mkdir("enumeration", 0o700, dir_fd=diagnostics_fd)
        except FileExistsError:
            pass
        return os.open("enumeration", os.O_RDONLY | directory_flags, dir_fd=diagnostics_fd)
    except (OSError, ValueError) as error:
        raise CaptureProblem("copy_failed reason=artifact_directory_isolation") from error
    finally:
        for descriptor in (diagnostics_fd, evidence_fd, root_fd):
            if descriptor is not None:
                os.close(descriptor)


def capture_enumeration_xcresult(
    build_root: Path,
    *,
    max_files: int = MAX_BUNDLE_FILES,
    max_bytes: int = MAX_BUNDLE_BYTES,
    copy_timeout_seconds: int = MAX_COPY_SECONDS,
    copy_command: tuple[str, ...] = ("ditto",),
) -> str:
    """Copy at most one identified Modules result bundle into diagnostic evidence."""
    build_root = build_root.resolve()
    try:
        diagnostics = prepare_diagnostics(build_root)
        bundles = discover_bundles(build_root)
        source, selection, source_inventory, skipped_candidates = select_modules_bundle(
            bundles, build_root, max_files, max_bytes
        )
        source_files, source_bytes = source_inventory
    except CaptureProblem as error:
        return f"enumeration_xcresult_capture={error}"

    staging_root = build_root / "diagnostic-staging"
    try:
        destination_directory_fd = open_enumeration_directory(build_root)
    except CaptureProblem as error:
        return f"enumeration_xcresult_capture={error}"
    try:
        try:
            if staging_root.is_symlink():
                return status_line("copy_failed", reason="staging_directory_isolation")
            staging_root.mkdir(parents=True, exist_ok=True)
            staging_root.resolve(strict=True).relative_to(build_root)
            with tempfile.TemporaryDirectory(prefix="enumeration-", dir=staging_root) as temporary:
                staged_bundle = Path(temporary) / "enumerate_Modules.xcresult"
                try:
                    copied = subprocess.run(
                        [*copy_command, str(source), str(staged_bundle)],
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                        timeout=copy_timeout_seconds,
                        check=False,
                    )
                except subprocess.TimeoutExpired:
                    return status_line("copy_timed_out", seconds=copy_timeout_seconds)
                except OSError:
                    return status_line("copy_failed", reason="copy_command")
                if copied.returncode != 0:
                    return status_line("copy_failed", command_status=copied.returncode)
                if not staged_bundle.is_dir():
                    return status_line("copy_failed", reason="copy_output_missing")
                try:
                    copied_files, copied_bytes = inventory_bundle(staged_bundle, max_files, max_bytes)
                except CaptureProblem:
                    return status_line("copy_failed", reason="copy_verification")
                if (copied_files, copied_bytes) != (source_files, source_bytes):
                    return status_line("copy_failed", reason="copy_verification")
                try:
                    os.stat(
                        "enumerate_Modules.xcresult",
                        dir_fd=destination_directory_fd,
                        follow_symlinks=False,
                    )
                except FileNotFoundError:
                    pass
                else:
                    return status_line(
                        "copy_failed", reason="artifact_limit_reached", max_artifacts=1
                    )
                os.replace(
                    staged_bundle,
                    "enumerate_Modules.xcresult",
                    dst_dir_fd=destination_directory_fd,
                )
        except (OSError, ValueError):
            return status_line("copy_failed", reason="artifact_destination")
    finally:
        os.close(destination_directory_fd)

    return status_line(
        "captured",
        selection=selection,
        files=source_files,
        bytes=source_bytes,
        max_files=max_files,
        max_bytes=max_bytes,
        max_copy_seconds=copy_timeout_seconds,
        max_artifacts=1,
        skipped_over_limit_candidates=skipped_candidates,
    )


def append_status(build_root: Path, outcome: str) -> bool:
    build_root = build_root.resolve()
    evidence = build_root / "evidence"
    diagnostics = evidence / "hosted-simulator-diagnostics"
    status_file = diagnostics / "collection-status.txt"
    try:
        if evidence.is_symlink() or diagnostics.is_symlink() or status_file.is_symlink():
            raise OSError("diagnostic status path is a symbolic link")
        diagnostics.resolve(strict=True).relative_to(build_root)
        flags = os.O_WRONLY | os.O_APPEND | os.O_CREAT | getattr(os, "O_NOFOLLOW", 0)
        descriptor = os.open(status_file, flags, 0o600)
        with os.fdopen(descriptor, "a", encoding="utf-8") as status:
            status.write(outcome + "\n")
    except (OSError, ValueError):
        print("::error::Could not safely record enumeration result capture status")
        return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("build_root", type=Path)
    parser.add_argument("--max-files", type=int, default=MAX_BUNDLE_FILES)
    parser.add_argument("--max-bytes", type=int, default=MAX_BUNDLE_BYTES)
    parser.add_argument("--copy-timeout-seconds", type=int, default=MAX_COPY_SECONDS)
    arguments = parser.parse_args()
    unexpected_error: Exception | None = None
    try:
        outcome = capture_enumeration_xcresult(
            arguments.build_root,
            max_files=arguments.max_files,
            max_bytes=arguments.max_bytes,
            copy_timeout_seconds=arguments.copy_timeout_seconds,
        )
    except CaptureProblem as error:
        outcome = f"enumeration_xcresult_capture={error}"
    except Exception as error:
        outcome = status_line("inspection_failed", reason=f"unexpected_{type(error).__name__}")
        unexpected_error = error
    if not append_status(arguments.build_root, outcome):
        if unexpected_error is not None:
            traceback.print_tb(unexpected_error.__traceback__)
        return 1
    if not outcome.startswith("enumeration_xcresult_capture=captured"):
        print(f"::warning::{outcome}")
    if unexpected_error is not None:
        traceback.print_tb(unexpected_error.__traceback__)
        print(f"::error::Enumeration result capture raised {type(unexpected_error).__name__}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
