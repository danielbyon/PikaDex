"""Exercise result selection, bounded copying, and failure handling with fixtures."""

from __future__ import annotations

import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import textwrap
import time
import unittest
from pathlib import Path
from unittest.mock import patch


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
HELPER_PATH = REPOSITORY_ROOT / "Scripts" / "capture_enumeration_xcresult.py"
SPEC = importlib.util.spec_from_file_location("capture_enumeration_xcresult", HELPER_PATH)
CAPTURE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
sys.modules[SPEC.name] = CAPTURE
SPEC.loader.exec_module(CAPTURE)


class EnumerationResultSelectionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="pikadex-enumeration-capture-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.build_root = self.root / "PikaDex-A2"
        self.test_logs = self.build_root / "work" / "DerivedData" / "Logs" / "Test"
        self.logs = self.build_root / "evidence" / "logs"
        self.diagnostics = self.build_root / "evidence" / "hosted-simulator-diagnostics"
        self.test_logs.mkdir(parents=True)
        self.logs.mkdir(parents=True)
        self.diagnostics.mkdir(parents=True)

    def make_bundle(self, name: str, payload: bytes) -> Path:
        bundle = self.test_logs / name
        bundle.mkdir()
        (bundle / "Info.plist").write_text("fixture bundle\n", encoding="utf-8")
        (bundle / "payload.bin").write_bytes(payload)
        return bundle

    def report_result(self, bundle: Path, exit_code: int = 0) -> None:
        (self.logs / "enumerate_Modules.log").write_text(
            "Test session results, code coverage, and logs:\n"
            f"\t{bundle}\n",
            encoding="utf-8",
        )
        (self.logs / "enumerate_Modules.exit").write_text(
            f"{exit_code}\n", encoding="utf-8"
        )

    def start_marker_writer(self, *steps: str) -> subprocess.Popen[bytes]:
        marker = self.logs / "enumerate_Modules.exit"
        marker.write_text("not_run\n", encoding="ascii")
        writer = self.root / "write_gate_markers.py"
        writer.write_text(
            textwrap.dedent(
                """
                import sys
                import time
                from pathlib import Path

                marker = Path(sys.argv[1])
                for step in sys.argv[2:]:
                    if step.startswith("sleep:"):
                        time.sleep(float(step.split(":", 1)[1]))
                    else:
                        marker.write_text(step + "\\n", encoding="ascii")
                """
            ),
            encoding="utf-8",
        )
        return subprocess.Popen([sys.executable, str(writer), str(marker), *steps])

    def wait_for_gate_writer(self, writer: subprocess.Popen[bytes]) -> None:
        try:
            self.assertEqual(writer.wait(timeout=5), 0)
        finally:
            if writer.poll() is None:
                writer.terminate()
                writer.wait(timeout=5)

    def test_not_run_in_progress_zero_marker_lifecycle(self) -> None:
        writer = self.start_marker_writer("sleep:0.03", "in_progress", "sleep:0.03", "0")
        try:
            exit_code = CAPTURE._wait_for_modules_gate(
                self.build_root, writer.pid, timeout_seconds=2, poll_seconds=0.005
            )
        finally:
            self.wait_for_gate_writer(writer)

        self.assertEqual(exit_code, 0)

    def test_not_run_and_in_progress_are_distinct_marker_states(self) -> None:
        marker = self.logs / "enumerate_Modules.exit"
        marker.write_text("not_run\n", encoding="ascii")
        self.assertEqual(CAPTURE._read_gate_exit(self.build_root), ("not_run", None))

        marker.write_text("in_progress\n", encoding="ascii")
        self.assertEqual(
            CAPTURE._read_gate_exit(self.build_root), ("in_progress", None)
        )

    def test_not_run_in_progress_two_marker_lifecycle(self) -> None:
        writer = self.start_marker_writer("sleep:0.03", "in_progress", "sleep:0.03", "2")
        try:
            exit_code = CAPTURE._wait_for_modules_gate(
                self.build_root, writer.pid, timeout_seconds=2, poll_seconds=0.005
            )
        finally:
            self.wait_for_gate_writer(writer)

        self.assertEqual(exit_code, 2)

    def test_verifier_exit_with_not_run_marker_is_not_reached(self) -> None:
        marker = self.logs / "enumerate_Modules.exit"
        marker.write_text("not_run\n", encoding="ascii")
        verifier = subprocess.Popen([sys.executable, "-c", "pass"])
        verifier.wait(timeout=5)

        with patch.object(CAPTURE, "_process_is_running", return_value=False):
            outcome = CAPTURE.observe_enumeration_result(
                self.build_root, verifier.pid, timeout_seconds=1
            )

        self.assertIn("reason=enumerate_Modules_gate_not_reached", outcome)

    def test_empty_or_partial_marker_reads_retry_until_terminal_status(self) -> None:
        marker = self.logs / "enumerate_Modules.exit"
        for transient in (b"", b"0"):
            with self.subTest(transient=transient):
                marker.write_bytes(transient)

                def finish_marker() -> None:
                    time.sleep(0.04)
                    marker.write_bytes(b"0\n")

                writer = threading.Thread(target=finish_marker)
                writer.start()
                try:
                    state, exit_code = CAPTURE._read_gate_exit(self.build_root)
                finally:
                    writer.join(timeout=2)

                self.assertEqual(state, "completed")
                self.assertEqual(exit_code, 0)

    def test_persistent_malformed_marker_is_an_inspection_error(self) -> None:
        marker = self.logs / "enumerate_Modules.exit"
        marker.write_text("corrupt\n", encoding="ascii")
        started = time.monotonic()

        with patch.object(CAPTURE, "_process_is_running", return_value=True):
            outcome = CAPTURE.observe_enumeration_result(
                self.build_root, os.getpid(), timeout_seconds=1
            )

        self.assertGreaterEqual(time.monotonic() - started, 0.45)
        self.assertIn(
            "enumeration_xcresult_capture=inspection_failed "
            "reason=enumeration_gate_marker_invalid",
            outcome,
        )
        staged_record = (
            self.build_root
            / "diagnostic-staging"
            / "enumeration-capture"
            / "capture-record.json"
        ).read_text(encoding="utf-8")
        self.assertIn("reason=enumeration_gate_marker_invalid", staged_record)
        published = CAPTURE.publish_staged_capture(self.build_root)
        self.assertIn("reason=enumeration_gate_marker_invalid", published)
        status = (self.diagnostics / "collection-status.txt").read_text(
            encoding="utf-8"
        )
        self.assertIn("reason=enumeration_gate_marker_invalid", status)

    def test_exact_logged_modules_path_wins_over_unexpected_summary_titles(self) -> None:
        modules = self.make_bundle("Test-Modules-fixture.xcresult", b"modules-result")
        other = self.make_bundle("Test-PokedexTests-fixture.xcresult", b"other-result")
        self.report_result(modules)

        with patch.object(CAPTURE, "_summary_title", return_value=("Unexpected title", True)):
            outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        retained = (
            self.diagnostics / "enumeration" / "enumerate_Modules.xcresult" / "payload.bin"
        )
        status = (self.diagnostics / "collection-status.txt").read_text(encoding="utf-8")
        self.assertTrue(outcome.startswith("enumeration_xcresult_capture=captured"), outcome)
        self.assertEqual(retained.read_bytes(), b"modules-result")
        self.assertIn("summary_title=Unexpected%20title", status)
        self.assertIn("name=Test-PokedexTests-fixture.xcresult", status)
        self.assertIn("summary_query_failure=not_queried_exact_log_path_only", status)
        self.assertEqual((other / "payload.bin").read_bytes(), b"other-result")

    def test_failed_enumeration_result_is_captured_and_gate_status_is_preserved(self) -> None:
        modules = self.make_bundle("Test-Modules-failed.xcresult", b"partial-result")
        self.report_result(modules, exit_code=65)

        with patch.object(CAPTURE, "_summary_title", return_value=(None, False)):
            outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        retained = (
            self.diagnostics / "enumeration" / "enumerate_Modules.xcresult" / "payload.bin"
        )
        status = (self.diagnostics / "collection-status.txt").read_text(encoding="utf-8")
        self.assertTrue(outcome.startswith("enumeration_xcresult_capture=captured"), outcome)
        self.assertEqual(retained.read_bytes(), b"partial-result")
        self.assertIn("gate_exit_code=65", outcome)
        self.assertEqual((self.logs / "enumerate_Modules.exit").read_text(), "65\n")
        self.assertIn("gate_exit_code=65", status)

    def test_incomplete_enumeration_records_missing_result_without_selecting_other_bundle(self) -> None:
        other = self.make_bundle("Test-PokedexTests-fixture.xcresult", b"not-modules")
        (self.logs / "enumerate_Modules.log").write_text(
            "xcodebuild enumeration failed before writing a result\n", encoding="utf-8"
        )
        (self.logs / "enumerate_Modules.exit").write_text("2\n", encoding="utf-8")

        outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertIn("reason=modules_result_path_not_reported", outcome)
        self.assertFalse(
            (self.diagnostics / "enumeration" / "enumerate_Modules.xcresult").exists()
        )
        self.assertEqual((other / "payload.bin").read_bytes(), b"not-modules")
        status = (self.diagnostics / "collection-status.txt").read_text(encoding="utf-8")
        self.assertIn("name=Test-PokedexTests-fixture.xcresult", status)
        self.assertIn("capture=not_attempted", status)

    def test_reported_path_outside_verified_test_logs_is_rejected(self) -> None:
        outside = self.root / "Test-Modules-outside.xcresult"
        outside.mkdir()
        (outside / "payload.bin").write_bytes(b"outside")
        candidate = self.make_bundle("Test-PokedexTests-fixture.xcresult", b"not-modules")
        self.report_result(outside)

        outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertIn("reason=reported_path_outside_test_logs", outcome)
        self.assertFalse(
            (self.diagnostics / "enumeration" / "enumerate_Modules.xcresult").exists()
        )
        self.assertEqual((candidate / "payload.bin").read_bytes(), b"not-modules")

    def test_observer_stages_result_before_it_disappears_from_derived_data(self) -> None:
        bundle_path = self.test_logs / "Test-Modules-transient.xcresult"
        producer = self.root / "produce_transient_result.py"
        producer.write_text(
            textwrap.dedent(
                """
                import os
                import time
                from pathlib import Path

                root = Path(os.environ["BUILD_ROOT"])
                bundle = root / "work/DerivedData/Logs/Test/Test-Modules-transient.xcresult"
                bundle.mkdir()
                (bundle / "Info.plist").write_text("fixture bundle\\n")
                (bundle / "payload.bin").write_bytes(b"transient-modules-result")
                log = root / "evidence/logs/enumerate_Modules.log"
                log.write_text("Test session results, code coverage, and logs:\\n\\t" + str(bundle) + "\\n")
                (root / "evidence/logs/enumerate_Modules.exit").write_text("0\\n")
                staged = root / "diagnostic-staging/enumeration-capture/enumerate_Modules.xcresult"
                deadline = time.monotonic() + 8
                while time.monotonic() < deadline and not staged.is_dir():
                    time.sleep(0.01)
                if not staged.is_dir():
                    raise SystemExit("observer did not stage the result promptly")
                import shutil
                shutil.rmtree(bundle)
                """
            ),
            encoding="utf-8",
        )
        environment = os.environ.copy()
        environment["BUILD_ROOT"] = str(self.build_root)
        producer_process = subprocess.Popen([sys.executable, str(producer)], env=environment)
        try:
            with patch.object(CAPTURE, "_summary_title", return_value=(None, False)):
                outcome = CAPTURE.observe_enumeration_result(
                    self.build_root, producer_process.pid, timeout_seconds=10, poll_seconds=0.01
                )
            self.assertEqual(producer_process.wait(timeout=10), 0)
        finally:
            if producer_process.poll() is None:
                producer_process.terminate()
                producer_process.wait(timeout=5)

        staged = (
            self.build_root
            / "diagnostic-staging"
            / "enumeration-capture"
            / "enumerate_Modules.xcresult"
            / "payload.bin"
        )
        self.assertTrue(outcome.startswith("enumeration_xcresult_capture=staged"), outcome)
        self.assertFalse(bundle_path.exists())
        self.assertEqual(staged.read_bytes(), b"transient-modules-result")

    def test_reported_symlink_is_rejected_without_reading_outside_bundle(self) -> None:
        outside = self.root / "outside.xcresult"
        outside.mkdir()
        sentinel = outside / "secret.txt"
        sentinel.write_text("outside sentinel\n", encoding="utf-8")
        link = self.test_logs / "Test-Modules-symlink.xcresult"
        link.symlink_to(outside, target_is_directory=True)
        self.report_result(link)

        with patch.object(CAPTURE, "_summary_title", return_value=(None, False)):
            outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertIn("reason=reported_bundle_symlink", outcome)
        self.assertEqual(sentinel.read_text(encoding="utf-8"), "outside sentinel\n")
        self.assertFalse((self.diagnostics / "enumeration").exists())
        status = (self.diagnostics / "collection-status.txt").read_text(encoding="utf-8")
        self.assertIn("capture=rejected_symlink", status)

    def test_bundle_replaced_by_symlink_after_discovery_is_rejected(self) -> None:
        bundle = self.make_bundle("Test-Modules-replaced.xcresult", b"original")
        outside = self.root / "outside.xcresult"
        outside.mkdir()
        (outside / "secret.txt").write_text("outside sentinel\n", encoding="utf-8")
        self.report_result(bundle)
        open_child = CAPTURE._open_child_directory
        replaced = False

        def replace_before_open(parent_fd: int, name: str, **kwargs: object) -> int:
            nonlocal replaced
            if name == bundle.name and kwargs.get("expected_identity") is not None and not replaced:
                shutil.rmtree(bundle)
                bundle.symlink_to(outside, target_is_directory=True)
                replaced = True
            return open_child(parent_fd, name, **kwargs)

        with patch.object(CAPTURE, "_open_child_directory", side_effect=replace_before_open):
            outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertTrue(replaced)
        self.assertIn("reason=reported_bundle_symlink", outcome)
        self.assertEqual((outside / "secret.txt").read_text(), "outside sentinel\n")

    def test_nested_directory_replacement_is_rejected_without_following_symlink(self) -> None:
        bundle = self.make_bundle("Test-Modules-nested-replacement.xcresult", b"payload")
        nested = bundle / "Data"
        nested.mkdir()
        (nested / "part.bin").write_bytes(b"inside")
        outside = self.root / "outside"
        outside.mkdir()
        secret = outside / "secret.txt"
        secret.write_text("outside sentinel\n", encoding="utf-8")
        self.report_result(bundle)
        inventory = CAPTURE._inventory_bundle_fd
        replaced = False

        def inventory_then_replace(fd: int, *args: object, **kwargs: object) -> tuple[int, int, dict]:
            nonlocal replaced
            result = inventory(fd, *args, **kwargs)
            if not replaced:
                shutil.rmtree(nested)
                nested.symlink_to(outside, target_is_directory=True)
                replaced = True
            return result

        with patch.object(CAPTURE, "_inventory_bundle_fd", side_effect=inventory_then_replace):
            outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertTrue(replaced)
        self.assertIn("reason=bundle_changed_before_copy", outcome)
        self.assertEqual(secret.read_text(encoding="utf-8"), "outside sentinel\n")
        self.assertFalse((self.diagnostics / "enumeration").exists())

    def test_size_and_file_count_limits_are_reported(self) -> None:
        for limit_name, options, expected in (
            ("bytes", {"max_bytes": 8}, "reason=over_size_limit"),
            ("files", {"max_files": 1}, "reason=file_count_limit"),
        ):
            with self.subTest(limit=limit_name):
                modules = self.make_bundle(f"Test-Modules-{limit_name}.xcresult", b"payload")
                if limit_name == "files":
                    (modules / "extra.bin").write_bytes(b"extra")
                self.report_result(modules)

                outcome = CAPTURE.capture_enumeration_xcresult(self.build_root, **options)

                self.assertIn(expected, outcome)
                self.assertFalse(
                    (self.diagnostics / "enumeration" / "enumerate_Modules.xcresult").exists()
                )
                shutil.rmtree(self.build_root / "diagnostic-staging", ignore_errors=True)
                status_file = self.diagnostics / "collection-status.txt"
                if status_file.exists():
                    status_file.unlink()

    def test_copy_timeout_is_reported(self) -> None:
        modules = self.make_bundle("Test-Modules-timeout.xcresult", b"payload")
        self.report_result(modules)
        copy_tree = CAPTURE._copy_tree

        def slow_copy(*args: object, **kwargs: object) -> None:
            time.sleep(5)
            copy_tree(*args, **kwargs)

        with patch.object(CAPTURE, "_copy_tree", side_effect=slow_copy):
            outcome = CAPTURE.capture_enumeration_xcresult(
                self.build_root, copy_timeout_seconds=1
            )

        self.assertIn("enumeration_xcresult_capture=copy_timed_out seconds=1", outcome)
        self.assertFalse(
            (self.diagnostics / "enumeration" / "enumerate_Modules.xcresult").exists()
        )

    def test_existing_artifact_is_preserved_at_the_one_artifact_limit(self) -> None:
        modules = self.make_bundle("Test-Modules-existing-artifact.xcresult", b"new-result")
        self.report_result(modules)
        existing = self.diagnostics / "enumeration" / "enumerate_Modules.xcresult"
        existing.mkdir(parents=True)
        sentinel = existing / "sentinel.txt"
        sentinel.write_text("existing artifact\n", encoding="utf-8")

        outcome = CAPTURE.capture_enumeration_xcresult(self.build_root)

        self.assertIn("reason=artifact_limit_reached", outcome)
        self.assertEqual(sentinel.read_text(encoding="utf-8"), "existing artifact\n")

    def test_workflow_wrapper_returns_the_canonical_verifier_status(self) -> None:
        workflow = (REPOSITORY_ROOT / ".github" / "workflows" / "ci.yml").read_text(
            encoding="utf-8"
        )
        step = workflow.split("      - name: Run canonical release verification\n", 1)[1]
        run_block = step.split("        run: |\n", 1)[1].split("      # Run this before", 1)[0]
        shell = textwrap.dedent(run_block)
        scripts = self.root / "workflow-fixture" / "Scripts"
        scripts.mkdir(parents=True)
        verifier = scripts / "pokedex-release-verification"
        verifier.write_text("#!/bin/sh\nexit \"$CANONICAL_STATUS\"\n", encoding="utf-8")
        verifier.chmod(0o755)
        observer = scripts / "capture_enumeration_xcresult.py"
        observer.write_text(
            "import os, sys\n"
            "sys.exit(int(os.environ['OBSERVER_STATUS']))\n",
            encoding="utf-8",
        )
        environment = os.environ.copy()
        environment["PIKADEX_RELEASE_BUILD_ROOT"] = str(self.build_root)
        for canonical_status, observer_status in ((0, 0), (2, 0), (65, 0), (0, 7)):
            with self.subTest(canonical_status=canonical_status, observer_status=observer_status):
                environment["CANONICAL_STATUS"] = str(canonical_status)
                environment["OBSERVER_STATUS"] = str(observer_status)
                result = subprocess.run(
                    ["bash", "-c", shell],
                    cwd=scripts.parent,
                    env=environment,
                    text=True,
                    capture_output=True,
                    timeout=10,
                )
                self.assertEqual(result.returncode, canonical_status, result.stderr)
                if observer_status:
                    self.assertIn("Enumeration result observer failed", result.stdout)


if __name__ == "__main__":
    unittest.main()
