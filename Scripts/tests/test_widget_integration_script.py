import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "run-widget-integration-test.sh"
SIMULATOR_ID = "A2CFE618-12AB-4937-B260-5CE009AC93E3"
SIMULATOR_NAME = "PikaDex Widget Integration Disposable fixture-run"


class WidgetIntegrationScriptTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory(
            prefix="pikadex-widget-integration-tests-"
        )
        self.root = Path(self.temporary_directory.name)
        self.fake_bin = self.root / "bin"
        self.fake_bin.mkdir()
        self._install_fake("uuidgen", 'print("fixture-run")\n')
        self._install_fake(
            "xcodebuild",
            """
import json
import os
import sys

with open(os.environ["FAKE_XCODEBUILD_ARGS"], "w", encoding="utf-8") as output:
    json.dump(sys.argv[1:], output)
sys.exit(int(os.environ.get("FAKE_XCODEBUILD_STATUS", "0")))
""",
        )
        self._install_fake(
            "xcrun",
            f"""
import json
import os
import sys

args = sys.argv[1:]
with open(os.environ["FAKE_XCRUN_LOG"], "a", encoding="utf-8") as output:
    output.write(json.dumps(args) + "\\n")

state_path = os.environ["FAKE_XCRUN_STATE"]
try:
    with open(state_path, encoding="utf-8") as source:
        state = json.load(source)
except FileNotFoundError:
    state = {{}}

if args[:2] == ["simctl", "create"]:
    print("{SIMULATOR_ID}")
elif args[:2] == ["simctl", "getenv"]:
    if args[-1] == "SIMULATOR_DEVICE_NAME":
        print(os.environ["FAKE_SIMULATOR_NAME"])
    elif args[-1] == "SIMULATOR_UDID":
        print("{SIMULATOR_ID}")
elif args[:2] == ["simctl", "spawn"]:
    operation = args[3:5]
    if operation == ["launchctl", "setenv"]:
        state[args[5]] = args[6]
        with open(state_path, "w", encoding="utf-8") as output:
            json.dump(state, output)
    elif operation == ["launchctl", "getenv"]:
        print(state.get(args[5], ""))
elif args[:2] == ["simctl", "delete"]:
    sys.exit(int(os.environ.get("FAKE_DELETE_STATUS", "0")))
elif args[:1] == ["xcresulttool"]:
    print(json.dumps({{"result": "Passed", "passedTests": 1, "failedTests": 0, "skippedTests": 0}}))
""",
        )

    def tearDown(self):
        self.temporary_directory.cleanup()

    def _install_fake(self, name, body):
        path = self.fake_bin / name
        path.write_text("#!/usr/bin/env python3\n" + body, encoding="utf-8")
        path.chmod(0o755)

    def _case(self, name):
        case = self.root / name
        case.mkdir()
        evidence = case / "evidence"
        derived_data = case / "DerivedData"
        cloned_packages = case / "PinnedPackages"
        database = case / "candidate.sqlite"
        database.write_bytes(b"candidate database fixture")
        return case, evidence, derived_data, cloned_packages, database

    def _run(self, case, evidence, *extra_arguments, database=None, xcodebuild_status=0):
        environment = os.environ.copy()
        environment["PATH"] = str(self.fake_bin) + os.pathsep + environment["PATH"]
        environment["FAKE_XCODEBUILD_ARGS"] = str(case / "xcodebuild-args.json")
        environment["FAKE_XCODEBUILD_STATUS"] = str(xcodebuild_status)
        environment["FAKE_XCRUN_LOG"] = str(case / "xcrun.jsonl")
        environment["FAKE_XCRUN_STATE"] = str(case / "xcrun-state.json")
        environment["FAKE_SIMULATOR_NAME"] = SIMULATOR_NAME
        if database is None:
            environment.pop("PIKADEX_GENERATED_DATABASE_PATH", None)
        else:
            environment["PIKADEX_GENERATED_DATABASE_PATH"] = str(database)

        return subprocess.run(
            ["bash", str(SCRIPT), str(evidence), *(str(value) for value in extra_arguments)],
            capture_output=True,
            text=True,
            env=environment,
            check=False,
        )

    def _xcodebuild_arguments(self, case):
        path = case / "xcodebuild-args.json"
        return json.loads(path.read_text(encoding="utf-8")) if path.exists() else []

    def _xcrun_calls(self, case):
        path = case / "xcrun.jsonl"
        if not path.exists():
            return []
        return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]

    def _assert_simulator_deleted(self, case):
        deletes = [
            call
            for call in self._xcrun_calls(case)
            if call[:2] == ["simctl", "delete"]
        ]
        self.assertEqual(deletes, [["simctl", "delete", SIMULATOR_ID]])

    def test_legacy_one_argument_keeps_xcodebuild_resolution_behavior(self):
        case, evidence, _, _, database = self._case("legacy")

        result = self._run(case, evidence, database=database)

        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = self._xcodebuild_arguments(case)
        for flag in (
            "-disableAutomaticPackageResolution",
            "-onlyUsePackageVersionsFromResolvedFile",
            "-skipPackageUpdates",
            "-clonedSourcePackagesDirPath",
        ):
            self.assertNotIn(flag, arguments)
        self.assertFalse(any(value.startswith("PIKADEX_GENERATED_DATABASE_PATH=") for value in arguments))
        self.assertEqual(
            arguments[arguments.index("-derivedDataPath") + 1],
            str((evidence / "DerivedData").resolve()),
        )
        self._assert_simulator_deleted(case)

    def test_explicit_inputs_bind_database_and_pinned_package_checkout(self):
        case, evidence, derived_data, cloned_packages, database = self._case("explicit")

        result = self._run(
            case,
            evidence,
            derived_data,
            cloned_packages,
            database=database,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = self._xcodebuild_arguments(case)
        for flag in (
            "-disableAutomaticPackageResolution",
            "-onlyUsePackageVersionsFromResolvedFile",
            "-skipPackageUpdates",
        ):
            self.assertIn(flag, arguments)
        self.assertEqual(
            arguments[arguments.index("-derivedDataPath") + 1],
            str(derived_data.resolve()),
        )
        self.assertEqual(
            arguments[arguments.index("-clonedSourcePackagesDirPath") + 1],
            str(cloned_packages.resolve()),
        )
        self.assertIn(
            f"PIKADEX_GENERATED_DATABASE_PATH={database.resolve()}",
            arguments,
        )
        self._assert_simulator_deleted(case)

    def test_external_derived_data_defaults_to_its_checked_source_packages_directory(self):
        case, evidence, derived_data, _, database = self._case("implicit-packages")
        source_packages = derived_data / "SourcePackages"

        result = self._run(case, evidence, derived_data, database=database)

        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = self._xcodebuild_arguments(case)
        self.assertEqual(
            arguments[arguments.index("-clonedSourcePackagesDirPath") + 1],
            str(source_packages.resolve()),
        )
        self._assert_simulator_deleted(case)

    def test_symlinked_implicit_source_packages_root_is_rejected(self):
        case, evidence, derived_data, _, database = self._case("symlinked-packages")
        derived_data.mkdir()
        (derived_data / "SourcePackages").symlink_to(SCRIPT.parents[2], target_is_directory=True)

        result = self._run(case, evidence, derived_data, database=database)

        self.assertEqual(result.returncode, 73, result.stderr)
        self.assertIn("Cloned package checkout", result.stderr)
        self.assertEqual(self._xcrun_calls(case), [])
        self.assertFalse(evidence.exists())

    def test_package_and_database_path_conflicts_are_rejected(self):
        case, evidence, derived_data, _, database = self._case("conflicting-packages")
        nested_packages = derived_data / "Packages"

        result = self._run(
            case,
            evidence,
            derived_data,
            nested_packages,
            database=database,
        )

        self.assertEqual(result.returncode, 73, result.stderr)
        self.assertIn("must not overlap", result.stderr)
        self.assertEqual(self._xcrun_calls(case), [])

    def test_database_inside_implicit_source_packages_is_rejected(self):
        case, evidence, derived_data, _, _ = self._case("database-overlap")
        source_packages = derived_data / "SourcePackages"
        source_packages.mkdir(parents=True)
        database = source_packages / "candidate.sqlite"
        database.write_bytes(b"candidate database fixture")

        result = self._run(case, evidence, derived_data, database=database)

        self.assertEqual(result.returncode, 73, result.stderr)
        self.assertIn("must not overlap", result.stderr)
        self.assertEqual(self._xcrun_calls(case), [])

    def test_explicit_invocation_requires_candidate_database(self):
        case, evidence, derived_data, cloned_packages, _ = self._case("missing-database")

        result = self._run(case, evidence, derived_data, cloned_packages)

        self.assertEqual(result.returncode, 73, result.stderr)
        self.assertIn("PIKADEX_GENERATED_DATABASE_PATH", result.stderr)
        self.assertEqual(self._xcrun_calls(case), [])

    def test_xcodebuild_failure_is_propagated_and_simulator_is_removed(self):
        case, evidence, derived_data, cloned_packages, database = self._case("build-failure")

        result = self._run(
            case,
            evidence,
            derived_data,
            cloned_packages,
            database=database,
            xcodebuild_status=42,
        )

        self.assertEqual(result.returncode, 42, result.stderr)
        self._assert_simulator_deleted(case)


if __name__ == "__main__":
    unittest.main()
