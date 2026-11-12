import errno
import hashlib
import io
import json
from contextlib import redirect_stderr
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch

from Scripts import release_verification as verification


class TestIdentifierTests(unittest.TestCase):
    def test_normalizes_compiled_enumeration_and_xctest_log_identities(self):
        self.assertEqual(
            verification.normalize_test_identifier(
                "PokedexTests.xctest/DeepLinkTests/testTeamRouteConstructionAndParsing()"
            ),
            "DeepLinkTests/testTeamRouteConstructionAndParsing",
        )
        self.assertEqual(
            verification.normalize_test_identifier("-[DeepLinkTests testTeamRouteConstructionAndParsing]"),
            "DeepLinkTests/testTeamRouteConstructionAndParsing",
        )
        self.assertEqual(
            verification.normalize_test_identifier(
                "-[DatabasePipelineTests.PipelineCoordinatorTests testVerifyDoesNotNeedOrInstallAnExistingDatabase]"
            ),
            "PipelineCoordinatorTests/testVerifyDoesNotNeedOrInstallAnExistingDatabase",
        )


class SourceProvenanceTests(unittest.TestCase):
    def test_source_provenance_preserves_dotfile_paths_and_hashes(self):
        with tempfile.TemporaryDirectory(prefix="pokedex-source-provenance-", dir="/private/tmp") as temporary_root:
            repository = Path(temporary_root)
            workflow = repository / ".github/workflows/ci.yml"
            workflow.parent.mkdir(parents=True)
            workflow.write_text("workflow contents\n", encoding="utf-8")
            expected_status = " M .github/workflows/ci.yml\n"

            def git_result(args, **_kwargs):
                if args[3] == "status":
                    stdout = expected_status
                elif args[3:5] == ["rev-parse", "HEAD"]:
                    stdout = "dc5166a889fa87c0b12ec1d0161cd66893f030b0\n"
                elif args[3:5] == ["branch", "--show-current"]:
                    stdout = "codex/issue-10-ci-parity\n"
                else:
                    raise AssertionError(f"Unexpected Git command: {args[3:]}")
                return Mock(returncode=0, stdout=stdout, stderr="")

            with (
                patch.object(verification, "REPOSITORY_ROOT", repository),
                patch.object(verification.subprocess, "run", side_effect=git_result),
            ):
                provenance = verification.VerificationRunner.__new__(verification.VerificationRunner)._source_provenance()

        self.assertEqual(provenance["changedPaths"], [{
            "status": " M",
            "path": ".github/workflows/ci.yml",
            "sha256": hashlib.sha256(b"workflow contents\n").hexdigest(),
        }])
        self.assertEqual(provenance["statusSha256"], hashlib.sha256(expected_status.encode()).hexdigest())

    def test_compiled_enumeration_json_provides_the_executable_inventory(self):
        document = {
            "testNodes": [
                {
                    "nodeType": "Test Suite",
                    "name": "DeepLinkTests",
                    "children": [
                        {
                            "nodeType": "Test Case",
                            "nodeIdentifier": "PokedexTests/DeepLinkTests/testValidRoute()",
                        }
                    ],
                }
            ]
        }

        self.assertEqual(
            verification.extract_enumerated_tests(document),
            ["DeepLinkTests/testValidRoute"],
        )

    def test_xcode_27_enumeration_values_provide_compiled_test_identities(self):
        document = {
            "errors": [],
            "values": [
                {
                    "kind": "plan",
                    "name": "Modules",
                    "children": [
                        {
                            "kind": "target",
                            "name": "PokedexCoreTests",
                            "children": [
                                {
                                    "kind": "class",
                                    "name": "GameTests",
                                    "children": [
                                        {"kind": "test", "name": "testStableIdentity()"}
                                    ],
                                }
                            ],
                        }
                    ],
                }
            ],
        }

        self.assertEqual(
            verification.extract_enumerated_tests(document),
            ["GameTests/testStableIdentity"],
        )

    def test_enumeration_errors_fail_closed_even_when_json_is_valid(self):
        with self.assertRaises(verification.VerificationError):
            verification.extract_enumerated_tests(
                {"errors": ["scheme failed to enumerate"], "values": []}
            )

    def test_unrecognized_enumeration_shape_fails_closed(self):
        with self.assertRaises(verification.VerificationError):
            verification.extract_enumerated_tests({"tests": []})

    def test_compiled_enumeration_rejects_duplicate_identities(self):
        document = {
            "testNodes": [
                {"nodeType": "Test Case", "nodeIdentifier": "Target/ExampleTests/testCase()"},
                {"nodeType": "Test Case", "nodeIdentifier": "Target/ExampleTests/testCase()"},
            ]
        }
        report = verification.reconcile_source_and_enumeration(
            ["ExampleTests/testCase"], verification.extract_enumerated_tests(document)
        )
        self.assertFalse(report["passed"])
        self.assertEqual(report["duplicateCompiledIdentities"], ["ExampleTests/testCase"])


class SourceExpectationTests(unittest.TestCase):
    def test_comments_and_helpers_are_not_test_declarations(self):
        source = """
        final class ExampleTests: XCTestCase {
            // func testCommentedOut() {}
            /* func testBlockCommentedOut() {} */
            func helper() { func testNestedHelper() {} }
            func testRealCase() {}
            let example = "func testStringContent() {}"
        }
        """

        self.assertEqual(
            verification.source_test_declarations(source),
            ["ExampleTests/testRealCase"],
        )

    def test_conditional_methods_are_candidates_not_executable_expectations(self):
        source = """
        final class ExampleTests: XCTestCase {
            func testAlwaysCompiled() {}
            #if os(iOS)
            func testIOSOnly() {}
            #else
            func testOtherPlatformOnly() {}
            #endif
        }
        """

        required, conditional = verification.source_test_expectations(source)
        self.assertEqual(required, ["ExampleTests/testAlwaysCompiled"])
        self.assertEqual(
            conditional,
            ["ExampleTests/testIOSOnly", "ExampleTests/testOtherPlatformOnly"],
        )
        report = verification.reconcile_source_and_enumeration(
            required,
            ["ExampleTests/testAlwaysCompiled"],
            conditional,
        )
        self.assertTrue(report["passed"], report)


class ResultReconciliationTests(unittest.TestCase):
    def setUp(self):
        self.expected = ["ExampleTests/testOne", "ExampleTests/testTwo"]

    def test_all_compiled_cases_pass(self):
        actual = [
            {"identifier": self.expected[0], "result": "Passed"},
            {"identifier": self.expected[1], "result": "Passed"},
        ]
        report = verification.reconcile_results(self.expected, actual, reported_total=2)
        self.assertTrue(report["passed"], report)

    def test_xcresult_tree_preserves_case_identity_and_result(self):
        document = {
            "testNodes": [
                {
                    "nodeType": "Test Suite",
                    "name": "PipelineCoordinatorTests",
                    "children": [
                        {
                            "nodeType": "Test Case",
                            "nodeIdentifier": "DatabasePipelineTests/DatabasePipelineTests.PipelineCoordinatorTests/testVerify()",
                            "result": "Passed",
                        }
                    ],
                }
            ]
        }
        self.assertEqual(
            verification._result_nodes(document),
            [{"identifier": "PipelineCoordinatorTests/testVerify", "result": "Passed"}],
        )

    def test_malformed_explicit_identity_cannot_fall_back_to_tree_names(self):
        for malformed in (None, "", 42):
            document = {
                "testNodes": [
                    {
                        "nodeType": "Test Suite",
                        "name": "ExampleTests",
                        "children": [
                            {
                                "nodeType": "Test Case",
                                "name": "testOne()",
                                "nodeIdentifier": malformed,
                                "result": "Passed",
                            }
                        ],
                    }
                ]
            }
            with self.subTest(identity=malformed):
                with self.assertRaisesRegex(
                    verification.VerificationError,
                    "malformed stable identity",
                ):
                    verification._result_nodes(document)

    def test_xcresult_tree_traverses_untyped_grouping_nodes_with_children(self):
        document = {
            "testNodes": [
                [
                    {
                        "name": "Grouping Wrapper",
                        "children": [
                            {
                                "nodeType": "Test Case",
                                "nodeIdentifier": "ExampleTests/testOne",
                                "result": "Passed",
                            }
                        ],
                    }
                ]
            ]
        }

        self.assertEqual(
            verification._result_nodes(document),
            [{"identifier": "ExampleTests/testOne", "result": "Passed"}],
        )

    def test_xcresult_tree_rejects_untyped_nodes_with_unrelated_payloads(self):
        document = {
            "testNodes": [
                {
                    "payload": [
                        {
                            "nodeType": "Test Case",
                            "nodeIdentifier": "ExampleTests/testOne",
                            "result": "Passed",
                        }
                    ]
                }
            ]
        }

        with self.assertRaisesRegex(verification.VerificationError, "must contain children"):
            verification._result_nodes(document)

    def test_xcresult_tree_rejects_unknown_leaf_nodes(self):
        document = {
            "testNodes": [
                {
                    "nodeType": "Test Plan",
                    "children": [
                        {
                            "nodeType": "Future Test Case",
                            "nodeIdentifier": "ExampleTests/testExtra",
                        }
                    ],
                }
            ]
        }

        with self.assertRaisesRegex(verification.VerificationError, "no child results"):
            verification._result_nodes(document)

    def test_xcresult_tree_retains_unexecuted_cases_as_not_run(self):
        document = {
            "testNodes": [
                {
                    "nodeType": "Test Suite",
                    "name": "ExampleTests",
                    "children": [
                        {"nodeType": "Test Case", "nodeIdentifier": "ExampleTests/testOne"},
                        {
                            "nodeType": "Test Case",
                            "nodeIdentifier": "ExampleTests/testTwo",
                            "result": "Passed",
                        },
                    ],
                }
            ]
        }

        result = verification._validate_xcresult_evidence(
            document,
            {"totalTestCount": 2},
            self.expected,
        )

        self.assertTrue(result["valid"])
        self.assertFalse(result["verification"]["passed"])
        self.assertIn("unknown_result", result["verification"]["issues"])
        self.assertEqual(
            result["cases"],
            [
                {"identifier": "ExampleTests/testOne", "result": "Not Run"},
                {"identifier": "ExampleTests/testTwo", "result": "Passed"},
            ],
        )

    def test_xcresult_summary_count_is_read_from_structured_summary(self):
        self.assertEqual(
            verification._summary_count({"totalTestCount": 17, "passedTests": 17}),
            17,
        )
        self.assertIsNone(
            verification._summary_count(
                {"statistics": {"totalTestCount": 17}}
            )
        )
        self.assertEqual(
            verification._summary_count(
                {"totalTestCount": 17, "statistics": {"totalTests": 16}}
            ),
            17,
        )
        for invalid in (True, -1, "17"):
            with self.subTest(invalid=invalid):
                self.assertIsNone(verification._summary_count({"totalTestCount": invalid}))

    def test_missing_extra_duplicate_skipped_failed_and_empty_are_rejected(self):
        scenarios = [
            ([{"identifier": self.expected[0], "result": "Passed"}], 1, "missing"),
            (
                [
                    {"identifier": self.expected[0], "result": "Passed"},
                    {"identifier": "ExampleTests/testExtra", "result": "Passed"},
                ],
                2,
                "extra",
            ),
            (
                [
                    {"identifier": self.expected[0], "result": "Passed"},
                    {"identifier": self.expected[0], "result": "Passed"},
                ],
                2,
                "duplicate",
            ),
            (
                [
                    {"identifier": self.expected[0], "result": "Passed"},
                    {"identifier": self.expected[1], "result": "Skipped"},
                ],
                2,
                "skipped",
            ),
            (
                [
                    {"identifier": self.expected[0], "result": "Passed"},
                    {"identifier": self.expected[1], "result": "Failed"},
                ],
                2,
                "failed",
            ),
            ([], 0, "empty"),
        ]
        for actual, reported_total, expected_issue in scenarios:
            with self.subTest(issue=expected_issue):
                report = verification.reconcile_results(
                    self.expected, actual, reported_total=reported_total
                )
                self.assertFalse(report["passed"])
                self.assertIn(expected_issue, report["issues"])

    def test_incomplete_summary_count_is_rejected(self):
        actual = [
            {"identifier": self.expected[0], "result": "Passed"},
            {"identifier": self.expected[1], "result": "Passed"},
        ]
        report = verification.reconcile_results(self.expected, actual, reported_total=3)
        self.assertIn("incomplete", report["issues"])

    def test_duplicate_expected_inventory_is_rejected(self):
        report = verification.reconcile_results(
            [self.expected[0], self.expected[0]],
            [{"identifier": self.expected[0], "result": "Passed"}],
            reported_total=1,
        )
        self.assertIn("duplicate_expected", report["issues"])

    def test_mac_xctest_output_requires_cases_and_a_complete_summary(self):
        good = """\
Test Case '-[ExampleTests testOne]' passed (0.001 seconds).
Test Case '-[ExampleTests testTwo]' passed (0.001 seconds).
Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.003) seconds
"""
        cases, total, issues = verification.parse_xctest_log(good)
        self.assertEqual(total, 2)
        self.assertEqual(len(cases), 2)
        self.assertEqual(issues, [])

        incomplete_cases, incomplete_total, incomplete_issues = verification.parse_xctest_log(
            "Test Case '-[ExampleTests testOne]' passed (0.001 seconds).\n"
        )
        self.assertIsNone(incomplete_total)
        self.assertIn("incomplete", incomplete_issues)
        self.assertEqual(len(incomplete_cases), 1)

    def test_indented_xctest_aggregate_summary_is_parsed(self):
        output = (
            "Test Case '-[ExampleTests testOne]' passed (0.001 seconds).\n"
            "\t Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.002) seconds\n"
        )

        cases, total, issues = verification.parse_xctest_log(output)

        self.assertEqual(total, 1)
        self.assertEqual(len(cases), 1)
        self.assertEqual(issues, [])

    def test_suite_summaries_are_reconciled_to_final_aggregate_count(self):
        output = """\
Test Case '-[FirstSuite testOne]' passed (0.001 seconds).
\t Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.002) seconds
Test Case '-[SecondSuite testTwo]' passed (0.001 seconds).
\t Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.002) seconds
Test Suite 'DatabasePipelineTests.xctest' passed at 2026-11-11 18:00:00.000.
\t Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.003) seconds
Test Suite 'All tests' passed at 2026-11-11 18:00:00.001.
\t Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.003) seconds
"""

        cases, total, issues = verification.parse_xctest_log(output)

        self.assertEqual(total, 2)
        self.assertEqual(len(cases), 2)
        self.assertEqual(issues, [])

    def test_mac_xctest_skips_and_failures_are_recorded(self):
        output = """\
Test Case '-[ExampleTests testOne]' passed (0.001 seconds).
Test Case '-[ExampleTests testTwo]' skipped (0.001 seconds).
Test Case '-[ExampleTests testThree]' failed (0.001 seconds).
Executed 3 tests, with 1 failure (1 unexpected) in 0.003 (0.004) seconds
"""
        cases, total, issues = verification.parse_xctest_log(output)
        report = verification.reconcile_results(
            ["ExampleTests/testOne", "ExampleTests/testTwo", "ExampleTests/testThree"],
            cases,
            total,
        )
        self.assertEqual([case["result"] for case in cases], ["Passed", "Skipped", "Failed"])
        self.assertEqual(issues, [])
        self.assertIn("skipped", report["issues"])
        self.assertIn("failed", report["issues"])


class SimulatorResultFallbackTests(unittest.TestCase):
    passing_log = """\
Test Case '-[ExampleTests testOne]' passed (0.001 seconds).
Test Case '-[ExampleTests testTwo]' passed (0.001 seconds).
Executed 2 tests, with 0 failures (0 unexpected) in 0.002 (0.003) seconds
"""
    valid_tests = {
        "testNodes": [
            {"nodeType": "Test Case", "nodeIdentifier": "ExampleTests/testOne", "result": "Passed"},
            {"nodeType": "Test Case", "nodeIdentifier": "ExampleTests/testTwo", "result": "Passed"},
        ]
    }

    def make_runner(
        self,
        evidence,
        log_text,
        exit_code,
        *,
        bundle_available=False,
        tests_document=None,
        summary_document=None,
        unavailable_exports=(),
    ):
        runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
        runner.evidence = evidence
        runner.simulator_destination = "platform=iOS Simulator,id=simulator-id"
        runner.derived_data = evidence / "DerivedData"
        runner.candidate = evidence / "candidate/Pokedex.sqlite"
        runner.provenance = {}
        runner.first_failure = None
        runner.gates = {}
        runner.manifest = {}
        runner.suite_records = {
            "Modules": {
                "compiledExecutableTests": ["ExampleTests/testOne", "ExampleTests/testTwo"]
            }
        }
        runner._xcode_build_args = lambda scheme, destination, action: ["xcodebuild", action]
        def write_fake_process_output(args, log, env=None):
            log.parent.mkdir(parents=True, exist_ok=True)
            log.write_text(log_text, encoding="utf-8")
            if bundle_available:
                (evidence / "results/Modules.xcresult").mkdir(parents=True, exist_ok=True)
            return exit_code

        runner._run_process = write_fake_process_output

        documents = {"tests": tests_document, "summary": summary_document}

        def export_result(bundle, kind, name, log):
            if bundle_available:
                bundle.mkdir(parents=True, exist_ok=True)
            if not bundle_available or kind in unavailable_exports:
                return None
            document = documents[kind]
            if document is not None:
                verification.atomic_json(evidence / "results" / f"{name}-{kind}.json", document)
            return document

        runner._export_xcresult = export_result
        return runner

    def execute(self, runner, evidence):
        runner._execute_suite(
            {"name": "Modules", "scheme": "Modules", "platform": "ios-simulator"},
            evidence / "logs/execute_Modules.log",
        )

    def assert_incomplete_result(self, runner, evidence):
        with self.assertRaises(verification.GateFailure) as raised:
            self.execute(runner, evidence)

        result = json.loads((evidence / "results/Modules-structured-results.json").read_text())
        self.assertNotEqual(raised.exception.exit_code, 0)
        self.assertFalse(result["xcresultEvidenceValid"])
        self.assertTrue(result["xcresultEvidenceIssues"])
        self.assertFalse(result["verification"]["passed"])
        return raised.exception, result

    def test_passing_console_log_cannot_pass_without_result_bundle(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = self.make_runner(evidence, self.passing_log, 0)
            error, result = self.assert_incomplete_result(runner, evidence)

            self.assertIn(error.failure_kind, {"evidence_invalid", "incomplete"})
            self.assertEqual(result["xcodebuildExitCode"], 0)
            self.assertEqual(result["verification"]["counts"]["passed"], 2)
            self.assertTrue((evidence / "logs/execute_Modules.log").is_file())
            self.assertTrue(any("bundle" in issue.lower() for issue in result["xcresultEvidenceIssues"]))

    def test_successful_structured_xcresult_reconciles_with_compiled_inventory(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = self.make_runner(
                evidence,
                self.passing_log,
                0,
                bundle_available=True,
                tests_document=self.valid_tests,
                summary_document={"totalTestCount": 2},
            )

            self.execute(runner, evidence)

            result = json.loads((evidence / "results/Modules-structured-results.json").read_text())
            self.assertEqual(result["resultSource"], "xcresult")
            self.assertTrue(result["xcresultEvidenceValid"])
            self.assertEqual(result["verification"]["counts"]["passed"], 2)
            self.assertTrue(result["verification"]["passed"])
            for name in ("Modules.xcresult", "Modules-tests.json", "Modules-summary.json"):
                self.assertTrue((evidence / "results" / name).exists())

    def test_missing_or_invalid_structured_exports_never_use_log_as_success_evidence(self):
        cases = (
            (
                "missing tests export",
                {"tests_document": self.valid_tests, "summary_document": {"totalTestCount": 2}, "unavailable_exports": ("tests",)},
            ),
            (
                "malformed test tree",
                {
                    "tests_document": {
                        "unexpected": {
                            "nodeType": "Test Plan",
                            "children": [
                                {
                                    "nodeType": "Test Case",
                                    "nodeIdentifier": "ExampleTests/testOne",
                                    "result": "Passed",
                                },
                                {
                                    "nodeType": "Test Case",
                                    "nodeIdentifier": "ExampleTests/testTwo",
                                    "result": "Passed",
                                },
                            ],
                        }
                    },
                    "summary_document": {"totalTestCount": 2},
                },
            ),
            (
                "empty test tree",
                {"tests_document": {"testNodes": []}, "summary_document": {"totalTestCount": 0}},
            ),
            (
                "missing summary export",
                {"tests_document": self.valid_tests, "summary_document": {"totalTestCount": 2}, "unavailable_exports": ("summary",)},
            ),
            (
                "malformed summary",
                {"tests_document": self.valid_tests, "summary_document": {"totalTestCount": "2"}},
            ),
            (
                "inconsistent summary count",
                {"tests_document": self.valid_tests, "summary_document": {"totalTestCount": 1}},
            ),
        )
        for label, options in cases:
            with self.subTest(case=label), tempfile.TemporaryDirectory() as directory:
                evidence = Path(directory)
                runner = self.make_runner(
                    evidence,
                    self.passing_log,
                    0,
                    bundle_available=True,
                    **options,
                )
                error, result = self.assert_incomplete_result(runner, evidence)
                self.assertIn(error.failure_kind, {"evidence_invalid", "incomplete"})
                self.assertEqual(result["xcodebuildExitCode"], 0)

    def test_missing_summary_document_is_nonpassing_even_with_passing_console_log(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = self.make_runner(
                evidence,
                self.passing_log,
                0,
                bundle_available=True,
                tests_document=self.valid_tests,
            )

            _, result = self.assert_incomplete_result(runner, evidence)

            self.assertTrue(any("summary" in issue.lower() for issue in result["xcresultEvidenceIssues"]))
            self.assertFalse(result["xcresultEvidenceValid"])
            self.assertIsNone(result["xcresultSummaryCount"])
            self.assertEqual(result["reportedTotalSource"], "xcodebuild-log")

    def test_disk_failure_retains_partial_counts_and_disk_disposition_without_xcresult(self):
        output = """\
Test Case '-[ExampleTests testOne]' passed (0.001 seconds).
xcodebuild: error: No space left on device
"""
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = self.make_runner(evidence, output, 65)

            with self.assertRaises(verification.GateFailure) as raised:
                runner._execute_suite(
                    {"name": "Modules", "scheme": "Modules", "platform": "ios-simulator"},
                    evidence / "logs/execute_Modules.log",
                )

            result = json.loads((evidence / "results/Modules-structured-results.json").read_text())
            self.assertEqual(raised.exception.exit_code, 65)
            self.assertEqual(raised.exception.failure_kind, "disk_exhaustion")
            self.assertEqual(result["verification"]["observedCount"], 1)
            self.assertIn("incomplete", result["verification"]["issues"])
            self.assertEqual(result["xcodebuildExitCode"], 65)
            self.assertFalse(result["xcresultEvidenceValid"])
            self.assertIn("No space left on device", (evidence / "logs/execute_Modules.log").read_text())


class XCResultExportTests(unittest.TestCase):
    def test_export_launch_failure_is_logged_and_returns_no_structured_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            bundle = evidence / "results/Modules.xcresult"
            bundle.mkdir(parents=True)
            log = evidence / "logs/execute_Modules.log"
            log.parent.mkdir()
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence

            with patch.object(
                verification.subprocess,
                "run",
                side_effect=FileNotFoundError("xcresulttool unavailable"),
            ):
                result = runner._export_xcresult(bundle, "tests", "Modules", log)

            self.assertIsNone(result)
            self.assertIn("xcresult export could not start", log.read_text(encoding="utf-8"))

    def test_export_failure_and_malformed_json_are_logged_and_not_exported(self):
        for label, kind, completed, expected_log in (
            ("failed export", "tests", Mock(returncode=65, stdout="partial output", stderr="export failed"), "export failed"),
            ("malformed tests JSON", "tests", Mock(returncode=0, stdout="{malformed", stderr=""), "{malformed"),
            ("malformed summary JSON", "summary", Mock(returncode=0, stdout="{malformed", stderr=""), "{malformed"),
        ):
            with self.subTest(case=label), tempfile.TemporaryDirectory() as directory:
                evidence = Path(directory)
                bundle = evidence / "results/Modules.xcresult"
                bundle.mkdir(parents=True)
                log = evidence / "logs/execute_Modules.log"
                log.parent.mkdir()
                runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
                runner.evidence = evidence
                destination = evidence / "results" / f"Modules-{kind}.json"
                destination.write_text('{"totalTestCount": 2}', encoding="utf-8")

                with patch.object(verification.subprocess, "run", return_value=completed):
                    result = runner._export_xcresult(bundle, kind, "Modules", log)

                self.assertIsNone(result)
                self.assertIn(expected_log, log.read_text(encoding="utf-8"))
                self.assertFalse(destination.exists())

    def test_missing_bundle_clears_stale_export(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            results = evidence / "results"
            results.mkdir()
            destination = results / "Modules-tests.json"
            destination.write_text('{"testNodes": []}', encoding="utf-8")
            log = evidence / "logs/execute_Modules.log"
            log.parent.mkdir()
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence

            result = runner._export_xcresult(results / "Modules.xcresult", "tests", "Modules", log)

            self.assertIsNone(result)
            self.assertFalse(destination.exists())


class MacSuiteIsolationTests(unittest.TestCase):
    def test_xcode_enumeration_is_not_wrapped_but_actual_xctest_uses_network_denial(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory) / "evidence"
            evidence.mkdir()
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence
            runner.derived_data = Path(directory) / "DerivedData"
            runner.work = Path(directory) / "work"
            runner.candidate = Path(directory) / "candidate/Pokedex.sqlite"
            runner.provenance = {}
            runner.suite_records = {
                "DatabasePipelineTests": {
                    "sourceTests": ["ExampleTests/testOne"],
                    "conditionalSourceTestCandidates": [],
                    "compiledExecutableTests": ["ExampleTests/testOne"],
                }
            }
            runner._xcode_build_args = lambda scheme, destination, action: [
                "/usr/bin/xcodebuild", action
            ]
            calls = []
            environments = []
            packaged_checks = []

            def enumerate_without_running_tests(args, log):
                calls.append(args)
                if "-test-enumeration-output-path" in args:
                    output = Path(args[args.index("-test-enumeration-output-path") + 1])
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_text(
                        json.dumps(
                            {
                                "values": [
                                    {
                                        "kind": "plan",
                                        "name": "DatabasePipelineTests",
                                        "children": [
                                            {
                                                "kind": "target",
                                                "name": "DatabasePipelineTests",
                                                "children": [
                                                    {
                                                        "kind": "class",
                                                        "name": "ExampleTests",
                                                        "children": [
                                                            {"kind": "test", "name": "testOne()"}
                                                        ],
                                                    }
                                                ],
                                            }
                                        ],
                                    }
                                ]
                            }
                        ),
                        encoding="utf-8",
                    )
                return 0

            runner._require_process = enumerate_without_running_tests
            runner._verify_packaged_candidate = lambda *args, **kwargs: packaged_checks.append(args)
            runner._write_manifest = lambda: None
            suite = {
                "name": "DatabasePipelineTests",
                "scheme": "DatabasePipelineTests",
                "targetName": "DatabasePipelineTests",
                "targetIdentifier": "test-target",
                "platform": "macos",
            }
            runner._enumerate_suite(suite, evidence / "enumeration.log")
            self.assertEqual(calls[0][0], "/usr/bin/xcodebuild")
            self.assertEqual(packaged_checks, [])
            runner._build_for_testing(suite, evidence / "build-for-testing.log")
            self.assertEqual(packaged_checks[0][1], "macos")

            bundle = runner.derived_data / "Build/Products/Debug/DatabasePipelineTests.xctest"
            bundle.mkdir(parents=True)
            xctest_log = (
                "Test Case '-[ExampleTests testOne]' passed (0.001 seconds).\n"
                "Executed 1 test, with 0 failures (0 unexpected) in 0.001 (0.002) seconds\n"
            )

            def run_isolated_xctest(args, log, env=None):
                calls.append(args)
                environments.append(env)
                log.parent.mkdir(parents=True, exist_ok=True)
                log.write_text(xctest_log, encoding="utf-8")
                return 0

            runner._run_process = run_isolated_xctest
            runner._execute_suite(suite, evidence / "execution.log")

            self.assertEqual(calls[2][0], str(verification.NETWORK_DENIED_XCTEST_RUNNER))
            self.assertEqual(
                environments[0]["LLVM_PROFILE_FILE"],
                str(runner.work / "Profiles" / "DatabasePipelineTests-%p.profraw"),
            )
            self.assertEqual(
                json.loads(
                    (evidence / "results/DatabasePipelineTests-structured-results.json").read_text()
                )["verification"]["counts"]["passed"],
                1,
            )


class FailureClassificationTests(unittest.TestCase):
    def test_startup_disk_exhaustion_is_reported_with_disk_exit_status(self):
        runner = Mock()
        runner.run.side_effect = OSError(errno.ENOSPC, "No space left on device")
        error_output = io.StringIO()

        with patch.object(verification, "VerificationRunner", return_value=runner):
            with redirect_stderr(error_output):
                result = verification.main()

        self.assertEqual(result, errno.ENOSPC)
        self.assertIn("disk_exhaustion", error_output.getvalue())

    def test_failure_reserve_exhaustion_preserves_startup_evidence(self):
        with tempfile.TemporaryDirectory(
            prefix="pokedex-release-startup-enospc-", dir="/private/tmp"
        ) as temporary_root:
            with patch.dict(verification.os.environ, {"PIKADEX_RELEASE_BUILD_ROOT": temporary_root}):
                runner = verification.VerificationRunner()
                with (
                    patch.object(runner, "_resolve_simulator", return_value=None),
                    patch.object(
                        runner,
                        "_reserve_failure_space",
                        side_effect=OSError(errno.ENOSPC, "No space left on device"),
                    ),
                ):
                    try:
                        result = runner.run()
                    except OSError as error:
                        self.fail(f"startup disk exhaustion escaped evidence finalization: {error}")

            manifest_path = runner.evidence / "manifest.json"
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
            preflight_log = (runner.evidence / "logs/preflight.log").read_text(encoding="utf-8")
            preflight_exit = (runner.evidence / "logs/preflight.exit").read_text(encoding="utf-8")
            completeness = json.loads(
                (runner.evidence / "evidence-completeness.json").read_text(encoding="utf-8")
            )

        self.assertEqual(result, errno.ENOSPC)
        self.assertEqual(manifest["runState"], "failed")
        self.assertEqual(manifest["firstFailure"]["gate"], "preflight")
        self.assertEqual(manifest["firstFailure"]["exitCode"], errno.ENOSPC)
        self.assertEqual(manifest["firstFailure"]["failureKind"], "disk_exhaustion")
        self.assertEqual(manifest["gates"]["preflight"]["status"], "failed")
        self.assertEqual(preflight_exit, f"{errno.ENOSPC}\n")
        self.assertIn("No space left on device", preflight_log)
        self.assertEqual(manifest["gates"]["crawler_provision"]["status"], "not_run")
        self.assertEqual(manifest["gates"]["source_database_integrity"]["status"], "passed")
        self.assertFalse(completeness["passed"])
        self.assertIn("toolchain.json", completeness["missingRequiredEvidence"])

    def test_preflight_disk_exhaustion_has_reserve_before_inventory_io(self):
        with tempfile.TemporaryDirectory(
            prefix="pokedex-release-preflight-enospc-", dir="/private/tmp"
        ) as temporary_root:
            with patch.dict(verification.os.environ, {"PIKADEX_RELEASE_BUILD_ROOT": temporary_root}):
                runner = verification.VerificationRunner()
                observed = {}

                def exhaust_during_inventory(_log):
                    observed["reserve_present"] = runner.failure_reserve.is_file()
                    raise OSError(errno.ENOSPC, "No space left on device")

                with patch.object(runner, "_resolve_simulator", side_effect=exhaust_during_inventory):
                    result = runner.run()

                manifest = json.loads((runner.evidence / "manifest.json").read_text(encoding="utf-8"))
                preflight_log = (runner.evidence / "logs/preflight.log").read_text(encoding="utf-8")
                reserve_remains = runner.failure_reserve.exists()

        self.assertEqual(result, errno.ENOSPC)
        self.assertTrue(observed["reserve_present"])
        self.assertFalse(reserve_remains)
        self.assertEqual(manifest["firstFailure"]["gate"], "preflight")
        self.assertEqual(manifest["firstFailure"]["failureKind"], "disk_exhaustion")
        self.assertIn("No space left on device", preflight_log)

    def test_terminal_manifest_uses_space_released_from_failure_reserve(self):
        with tempfile.TemporaryDirectory(
            prefix="pokedex-release-final-manifest-", dir="/private/tmp"
        ) as temporary_root:
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = Path(temporary_root) / "evidence"
            runner.evidence.mkdir()
            runner.work = Path(temporary_root) / "work"
            runner.work.mkdir()
            runner.failure_reserve = runner.work / ".failure-reserve"
            runner.failure_reserve.write_bytes(b"reserved")
            runner.first_failure = None
            runner.manifest = {}
            runner.gates = {}
            runner.suite_records = {}

            original_write_manifest = runner._write_manifest

            def write_manifest_with_disk_pressure():
                if runner.manifest.get("finishedAt") and runner.failure_reserve.exists():
                    raise OSError(errno.ENOSPC, "No space left on device")
                original_write_manifest()

            with (
                patch.object(runner, "_initialize"),
                patch.object(runner, "_plan", return_value=[]),
                patch.object(runner, "_gate", return_value=True),
                patch.object(runner, "_write_manifest", side_effect=write_manifest_with_disk_pressure),
            ):
                try:
                    result = runner.run()
                except OSError as error:
                    self.fail(f"terminal manifest write used space still held in reserve: {error}")

            manifest = json.loads((runner.evidence / "manifest.json").read_text(encoding="utf-8"))

        self.assertEqual(result, 0)
        self.assertEqual(manifest["runState"], "passed")
        self.assertFalse(runner.failure_reserve.exists())

    def test_macos_inventory_precedes_test_build_and_execution(self):
        runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
        runner.configuration = {
            "suites": [{"name": "DatabasePipelineTests", "platform": "macos"}]
        }

        plan_names = [name for name, _action in runner._plan()]
        gate_names = runner._planned_gate_names()

        self.assertLess(
            plan_names.index("enumerate_DatabasePipelineTests"),
            plan_names.index("build_for_testing_DatabasePipelineTests"),
        )
        self.assertLess(
            gate_names.index("enumerate_DatabasePipelineTests"),
            gate_names.index("build_for_testing_DatabasePipelineTests"),
        )

    def test_process_is_stopped_when_full_log_cannot_be_written(self):
        class FailOnProcessOutput:
            def __init__(self):
                self.writes = 0

            def __enter__(self):
                return self

            def __exit__(self, *_args):
                return False

            def write(self, _value):
                self.writes += 1
                if self.writes == 2:
                    raise OSError(errno.ENOSPC, "No space left on device")

            def flush(self):
                pass

        process = Mock()
        process.stdout = io.StringIO("build output\n")
        process.poll.return_value = None
        process.wait.return_value = 0
        log = FailOnProcessOutput()
        runner = verification.VerificationRunner.__new__(verification.VerificationRunner)

        with tempfile.TemporaryDirectory() as directory:
            with patch.object(Path, "open", return_value=log):
                with patch.object(verification.subprocess, "Popen", return_value=process):
                    with self.assertRaises(OSError) as raised:
                        runner._run_process(["xcodebuild"], Path(directory) / "build.log")

        self.assertEqual(raised.exception.errno, errno.ENOSPC)
        process.terminate.assert_called_once()
        process.wait.assert_called_once()

    def test_failure_classification_distinguishes_disk_and_infrastructure(self):
        self.assertEqual(
            verification.classify_failure("xcodebuild: error: No space left on device"),
            "disk_exhaustion",
        )
        self.assertEqual(
            verification.classify_failure("Unable to find a destination matching the provided destination specifier"),
            "infrastructure_unavailable",
        )
        self.assertEqual(
            verification.classify_failure("Test Case failed: assertion did not hold"),
            "test_failure",
        )
        self.assertEqual(
            verification.classify_failure("pipeline operation timed out"),
            "gate_failure",
        )

    def test_known_infrastructure_and_disk_errors_override_partial_result_classification(self):
        partial = {"issues": ["missing", "incomplete"]}
        self.assertEqual(
            verification.classify_test_result_failure("No space left on device", partial),
            "disk_exhaustion",
        )
        self.assertEqual(
            verification.classify_test_result_failure("Unable to find a destination", partial),
            "infrastructure_unavailable",
        )
        self.assertEqual(
            verification.classify_test_result_failure("pipeline operation timed out", partial),
            "incomplete",
        )

    def test_simulator_boot_and_process_launch_failures_are_infrastructure(self):
        partial = {"issues": ["missing", "incomplete"]}
        self.assertEqual(
            verification.classify_failure(
                "CoreSimulator: Failed to boot device with error attaching its disk image"
            ),
            "infrastructure_unavailable",
        )
        self.assertEqual(
            verification.classify_test_result_failure(
                "process launch failed: [Errno 2] No such file or directory: xcodebuild",
                partial,
            ),
            "infrastructure_unavailable",
        )

    def test_disk_exhaustion_releases_reserved_space_and_finalizes_gate_evidence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            evidence = root / "evidence"
            logs = evidence / "logs"
            logs.mkdir(parents=True)
            reserve = root / "work" / ".failure-reserve"
            reserve.parent.mkdir()
            reserve.write_bytes(b"reserved space")

            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence
            runner.failure_reserve = reserve
            runner.gates = {"pokedex_build": {"status": "not_run"}}
            runner.first_failure = None
            runner._write_manifest = lambda: None

            def exhaust_disk(_log):
                raise OSError(errno.ENOSPC, "No space left on device")

            self.assertFalse(runner._gate("pokedex_build", exhaust_disk))

            self.assertFalse(reserve.exists())
            self.assertEqual(runner.gates["pokedex_build"]["failureKind"], "disk_exhaustion")
            self.assertEqual(runner.gates["pokedex_build"]["exitCode"], errno.ENOSPC)
            self.assertEqual(runner.first_failure["failureKind"], "disk_exhaustion")
            self.assertEqual((logs / "pokedex_build.exit").read_text(), f"{errno.ENOSPC}\n")
            self.assertIn("RUNNER ERROR: OSError", (logs / "pokedex_build.log").read_text())

    def test_network_probe_failure_is_reported_as_an_isolation_failure(self):
        runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
        with tempfile.TemporaryDirectory() as directory:
            runner.evidence = Path(directory)
            runner.provenance = {}
            with patch.object(runner, "_run_process", return_value=4):
                with self.assertRaises(verification.GateFailure) as raised:
                    runner._network_probe(Path(directory) / "network.log")
        self.assertEqual(raised.exception.failure_kind, "network_isolation_failure")


class CrawlerProvisioningTests(unittest.TestCase):
    def test_sparse_checkout_roots_include_only_pinned_crawler_inputs(self):
        roots = verification.reviewed_input_sparse_roots(
            [
                {"path": "Crawlers/Data/Abilities.json"},
                {"path": "Research/AbilitiesGeneration9.json"},
            ]
        )
        self.assertEqual(roots, ["Data"])

    def test_sparse_checkout_rejects_paths_that_escape_the_pinned_checkout(self):
        with self.assertRaises(verification.VerificationError):
            verification.reviewed_input_sparse_roots([{"path": "Research/../outside.tsv"}])


class CandidateDatabaseBindingTests(unittest.TestCase):
    def test_candidate_must_keep_the_hash_recorded_by_offline_validation(self):
        with tempfile.TemporaryDirectory() as directory:
            candidate = Path(directory) / "Pokedex.sqlite"
            candidate.write_bytes(b"validated candidate")
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.candidate = candidate
            runner.provenance = {
                "candidateDatabase": {"sha256": verification.sha256_file(candidate)}
            }

            self.assertEqual(
                runner._require_validated_candidate_hash(),
                verification.sha256_file(candidate),
            )
            candidate.write_bytes(b"different candidate")
            with self.assertRaises(verification.GateFailure) as raised:
                runner._require_validated_candidate_hash()
            self.assertEqual(raised.exception.failure_kind, "candidate_binding")

    def test_matching_framework_resource_inside_app_bundle_is_verified(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            candidate = root / "candidate/Pokedex.sqlite"
            candidate.parent.mkdir()
            candidate.write_bytes(b"validated candidate")
            product = (
                root
                / "DerivedData/Build/Products/Debug-iphonesimulator/PikaDex.app/Frameworks"
                / "PokedexCore.framework/Pokedex.sqlite"
            )
            product.parent.mkdir(parents=True)
            product.write_bytes(candidate.read_bytes())
            evidence = root / "evidence"
            evidence.mkdir()
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.candidate = candidate
            runner.derived_data = root / "DerivedData"
            runner.evidence = evidence
            runner.provenance = {
                "candidateDatabase": {"sha256": verification.sha256_file(candidate)},
                "packagedCatalogs": [],
            }

            runner._verify_packaged_candidate(
                evidence / "build.log", "ios-simulator", require_app_bundle=True
            )

            record = runner.provenance["packagedCatalogs"][0]
            self.assertTrue(record["matchesCandidate"])
            self.assertIn("ios-simulator", record["verifiedFor"])

    def test_versioned_macos_framework_resource_is_verified(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            candidate = root / "candidate/Pokedex.sqlite"
            candidate.parent.mkdir()
            candidate.write_bytes(b"validated candidate")
            product = (
                root
                / "DerivedData/Build/Products/Debug/PokedexCore.framework/Versions/A/Resources"
                / "Pokedex.sqlite"
            )
            product.parent.mkdir(parents=True)
            product.write_bytes(candidate.read_bytes())
            evidence = root / "evidence"
            evidence.mkdir()
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.candidate = candidate
            runner.derived_data = root / "DerivedData"
            runner.evidence = evidence
            runner.provenance = {
                "candidateDatabase": {"sha256": verification.sha256_file(candidate)},
                "packagedCatalogs": [],
            }

            runner._verify_packaged_candidate(evidence / "build.log", "macos")

            record = runner.provenance["packagedCatalogs"][0]
            self.assertTrue(record["matchesCandidate"])
            self.assertIn("macos", record["verifiedFor"])


class SuiteConfigurationTests(unittest.TestCase):
    def test_configuration_cannot_remove_any_original_required_suite(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "suites.json"
            path.write_text(
                json.dumps({"requiredSuites": ["Modules"], "suites": []}),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(verification.VerificationError, "original suites"):
                verification._load_config(path)


class ArtifactScopeTests(unittest.TestCase):
    def test_pipeline_report_collection_excludes_normalized_sources_and_database(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.pipeline_output = root / "output"
            runner.evidence = root / "evidence"
            reports = runner.pipeline_output / "reports"
            reports.mkdir(parents=True)
            for name in ("preflight.json", "preflight.txt", "validation.json", "validation.txt"):
                (reports / name).write_text(name, encoding="utf-8")
            normalized = runner.pipeline_output / "normalized-inputs" / "Data.json"
            normalized.parent.mkdir()
            normalized.write_text("source copy", encoding="utf-8")
            candidate = runner.pipeline_output / "candidate" / "Pokedex.sqlite"
            candidate.parent.mkdir()
            candidate.write_bytes(b"database")

            copied = runner._collect_pipeline_reports()

            self.assertEqual(len(copied), 4)
            self.assertTrue(all((runner.evidence / item).is_file() for item in copied))
            self.assertFalse((runner.evidence / "reports/pipeline/Data.json").exists())
            self.assertFalse((runner.evidence / "reports/pipeline/Pokedex.sqlite").exists())

    def test_passed_simulator_suite_requires_all_structured_xcresult_artifacts(self):
        required_artifacts = (
            "results/Modules.xcresult",
            "results/Modules-tests.json",
            "results/Modules-summary.json",
            "results/Modules-structured-results.json",
        )
        for missing_artifact in required_artifacts:
            with self.subTest(missing=missing_artifact), tempfile.TemporaryDirectory() as directory:
                evidence = Path(directory)
                runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
                runner.evidence = evidence
                runner.configuration = {"suites": [{"name": "Modules", "platform": "ios-simulator"}]}
                runner.gate_names = ["enumerate_Modules", "execute_Modules"]
                runner.gates = {
                    "enumerate_Modules": {"status": "passed"},
                    "execute_Modules": {"status": "passed"},
                }
                expected = ["ExampleTests/testOne", "ExampleTests/testTwo"]
                runner.suite_records = {
                    "Modules": {"executionStarted": True, "compiledExecutableTests": expected}
                }
                for name in ("manifest.json", "provenance.json", "toolchain.json"):
                    (evidence / name).write_text("{}", encoding="utf-8")
                for name in runner.gate_names:
                    path = evidence / "logs" / f"{name}.log"
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text("", encoding="utf-8")
                    path.with_suffix(".exit").write_text("0\n", encoding="utf-8")
                inventory = evidence / "inventory/Modules.json"
                inventory.parent.mkdir()
                inventory.write_text("{}", encoding="utf-8")
                results = evidence / "results"
                results.mkdir()
                (results / "Modules.xcresult").mkdir()
                tests_document = {
                    "testNodes": [
                        {"nodeType": "Test Case", "nodeIdentifier": identity, "result": "Passed"}
                        for identity in expected
                    ]
                }
                cases = verification._result_nodes(tests_document)
                result_report = verification.reconcile_results(expected, cases, 2)
                (results / "Modules-tests.json").write_text(json.dumps(tests_document), encoding="utf-8")
                (results / "Modules-summary.json").write_text('{"totalTestCount": 2}', encoding="utf-8")
                (results / "Modules-structured-results.json").write_text(
                    json.dumps(
                        {
                            "resultSource": "xcresult",
                            "xcodebuildExitCode": 0,
                            "xcresultBundleAvailable": True,
                            "xcresultTestsExported": True,
                            "xcresultSummaryExported": True,
                            "xcresultEvidenceValid": True,
                            "xcresultEvidenceIssues": [],
                            "xcresultObservedCount": 2,
                            "xcresultSummaryCount": 2,
                            "verification": result_report,
                        }
                    ),
                    encoding="utf-8",
                )
                target = evidence / missing_artifact
                if target.is_dir():
                    target.rmdir()
                else:
                    target.unlink()

                with self.assertRaises(verification.GateFailure) as raised:
                    runner._evidence_completeness(evidence / "completeness.log")

                report = json.loads((evidence / "evidence-completeness.json").read_text())
                self.assertEqual(raised.exception.failure_kind, "incomplete")
                self.assertFalse(report["passed"])
                self.assertIn(missing_artifact, report["missingRequiredEvidence"])

    def test_complete_reconciled_simulator_evidence_passes_finalization(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence
            runner.configuration = {"suites": [{"name": "Modules", "platform": "ios-simulator"}]}
            runner.gate_names = ["enumerate_Modules", "execute_Modules"]
            runner.gates = {
                "enumerate_Modules": {"status": "passed"},
                "execute_Modules": {"status": "passed"},
            }
            expected = ["ExampleTests/testOne", "ExampleTests/testTwo"]
            runner.suite_records = {
                "Modules": {"executionStarted": True, "compiledExecutableTests": expected}
            }
            for name in ("manifest.json", "provenance.json", "toolchain.json"):
                (evidence / name).write_text("{}", encoding="utf-8")
            for name in runner.gate_names:
                path = evidence / "logs" / f"{name}.log"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("", encoding="utf-8")
                path.with_suffix(".exit").write_text("0\n", encoding="utf-8")
            inventory = evidence / "inventory/Modules.json"
            inventory.parent.mkdir()
            inventory.write_text("{}", encoding="utf-8")
            results = evidence / "results"
            results.mkdir()
            (results / "Modules.xcresult").mkdir()
            tests_document = {
                "testNodes": [
                    {"nodeType": "Test Case", "nodeIdentifier": identity, "result": "Passed"}
                    for identity in expected
                ]
            }
            cases = verification._result_nodes(tests_document)
            result_report = verification.reconcile_results(expected, cases, 2)
            (results / "Modules-tests.json").write_text(json.dumps(tests_document), encoding="utf-8")
            (results / "Modules-summary.json").write_text('{"totalTestCount": 2}', encoding="utf-8")
            (results / "Modules-structured-results.json").write_text(
                json.dumps(
                    {
                        "resultSource": "xcresult",
                            "xcodebuildExitCode": 0,
                        "xcresultBundleAvailable": True,
                        "xcresultTestsExported": True,
                        "xcresultSummaryExported": True,
                        "xcresultEvidenceValid": True,
                            "xcresultEvidenceIssues": [],
                        "xcresultObservedCount": 2,
                        "xcresultSummaryCount": 2,
                        "verification": result_report,
                    }
                ),
                encoding="utf-8",
            )

            runner._evidence_completeness(evidence / "completeness.log")

            report = json.loads((evidence / "evidence-completeness.json").read_text())
            self.assertTrue(report["passed"], report)

    def test_started_suite_records_missing_results_without_overwriting_first_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            evidence = Path(directory)
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.evidence = evidence
            runner.configuration = {"suites": [{"name": "Modules", "platform": "ios-simulator"}]}
            runner.gate_names = ["enumerate_Modules", "execute_Modules", "evidence_completeness"]
            runner.gates = {
                "enumerate_Modules": {"status": "passed"},
                "execute_Modules": {"status": "failed"},
                "evidence_completeness": {"status": "not_run", "exitCode": None, "failureKind": None},
            }
            runner.first_failure = {
                "gate": "execute_Modules",
                "exitCode": 65,
                "failureKind": "disk_exhaustion",
                "message": "No space left on device",
            }
            first_failure = runner.first_failure.copy()
            runner._write_manifest = lambda: None
            runner.suite_records = {"Modules": {"executionStarted": True}}
            for name in ("manifest.json", "provenance.json", "toolchain.json"):
                (evidence / name).write_text("{}", encoding="utf-8")
            for name in runner.gate_names:
                path = evidence / "logs" / f"{name}.log"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("", encoding="utf-8")
                path.with_suffix(".exit").write_text("1\n", encoding="utf-8")
            inventory = evidence / "inventory/Modules.json"
            inventory.parent.mkdir()
            inventory.write_text("{}", encoding="utf-8")

            self.assertFalse(runner._gate("evidence_completeness", runner._evidence_completeness))
            report = json.loads((evidence / "evidence-completeness.json").read_text())
            self.assertEqual(runner.first_failure, first_failure)
            self.assertIn("results/Modules-structured-results.json", report["missingRequiredEvidence"])
            self.assertIn("results/Modules.xcresult", report["missingRequiredEvidence"])
            self.assertIn("results/Modules-tests.json", report["missingRequiredEvidence"])
            self.assertIn("results/Modules-summary.json", report["missingRequiredEvidence"])


class RootSafetyTests(unittest.TestCase):
    def test_ownership_marker_symlink_is_rejected_without_following_it(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory).resolve()
            root = parent / "verification"
            root.mkdir()
            outside = parent / "outside.txt"
            outside.write_text("preserve", encoding="utf-8")
            marker = root / ".pokedex-release-verification"
            marker.symlink_to(outside)
            runner = verification.VerificationRunner.__new__(verification.VerificationRunner)
            runner.root_input = root
            runner.root = root
            runner.root_marker = marker

            with self.assertRaisesRegex(verification.VerificationError, "symbolic link"):
                runner._validate_root()
            self.assertEqual(outside.read_text(encoding="utf-8"), "preserve")


if __name__ == "__main__":
    unittest.main()
