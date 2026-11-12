import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "check-generated-pokedex-database.sh"
RESOURCE_RELATIVE_PATH = Path("Products/PokedexCore.framework/Pokedex.sqlite")


class GeneratedDatabaseSelectionTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        self.source_database = self.root / "Modules/PokedexCore/Resources/Database/Pokedex.sqlite"
        self.source_database.parent.mkdir(parents=True)
        self.target_build_directory = self.root / "Build"
        self.resource = self.target_build_directory / RESOURCE_RELATIVE_PATH

    def tearDown(self):
        self.temporary_directory.cleanup()

    def run_copy_phase(self, candidate=None, skip_check=False):
        environment = os.environ.copy()
        environment.update(
            {
                "SRCROOT": str(self.root),
                "TARGET_BUILD_DIR": str(self.target_build_directory),
                "UNLOCALIZED_RESOURCES_FOLDER_PATH": "Products/PokedexCore.framework",
            }
        )
        if candidate is None:
            environment.pop("PIKADEX_GENERATED_DATABASE_PATH", None)
        else:
            environment["PIKADEX_GENERATED_DATABASE_PATH"] = str(candidate)
        if skip_check:
            environment["PIKADEX_SKIP_GENERATED_DATABASE_CHECK"] = "YES"
        return subprocess.run(
            ["/bin/sh", str(SCRIPT)],
            env=environment,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_explicit_candidate_is_packaged_without_changing_default_database(self):
        self.source_database.write_bytes(b"developer database")
        sidecars = {
            suffix: Path(f"{self.source_database}{suffix}")
            for suffix in ("-wal", "-shm", "-journal")
        }
        for suffix, sidecar in sidecars.items():
            sidecar.write_bytes(f"developer sidecar {suffix}".encode())
        candidate = self.root / "candidate/Pokedex.sqlite"
        candidate.parent.mkdir()
        candidate.write_bytes(b"validated candidate")

        result = self.run_copy_phase(candidate)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.resource.read_bytes(), b"validated candidate")
        self.assertEqual(self.source_database.read_bytes(), b"developer database")
        for suffix, sidecar in sidecars.items():
            self.assertEqual(sidecar.read_bytes(), f"developer sidecar {suffix}".encode())

    def test_missing_explicit_candidate_fails_without_fallback_or_stale_resource(self):
        self.source_database.write_bytes(b"developer database")
        self.resource.parent.mkdir(parents=True)
        self.resource.write_bytes(b"stale packaged database")
        missing_candidate = self.root / "missing/Pokedex.sqlite"

        result = self.run_copy_phase(missing_candidate)

        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.resource.exists())
        self.assertEqual(self.source_database.read_bytes(), b"developer database")

    def test_repeated_build_replaces_resource_when_candidate_bytes_change(self):
        self.source_database.write_bytes(b"developer database")
        first_candidate = self.root / "candidate/first.sqlite"
        second_candidate = self.root / "candidate/second.sqlite"
        first_candidate.parent.mkdir()
        first_candidate.write_bytes(b"first candidate")
        second_candidate.write_bytes(b"second candidate")

        first_result = self.run_copy_phase(first_candidate)
        second_result = self.run_copy_phase(second_candidate)

        self.assertEqual(first_result.returncode, 0, first_result.stderr)
        self.assertEqual(second_result.returncode, 0, second_result.stderr)
        self.assertEqual(self.resource.read_bytes(), b"second candidate")

    def test_no_override_keeps_the_ordinary_source_database_behavior(self):
        self.source_database.write_bytes(b"ordinary generated database")

        result = self.run_copy_phase()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.resource.read_bytes(), b"ordinary generated database")

    def test_tooling_skip_is_preserved_when_no_candidate_override_is_selected(self):
        self.resource.parent.mkdir(parents=True)
        self.resource.write_bytes(b"stale resource")

        result = self.run_copy_phase(skip_check=True)

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.resource.exists())


if __name__ == "__main__":
    unittest.main()
