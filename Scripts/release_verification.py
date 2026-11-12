#!/usr/bin/env python3
"""Run the shared, evidence-producing PikaDex CI and local verification gate."""

from __future__ import annotations

import collections
import datetime as dt
import errno
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import sys
import xml.etree.ElementTree as ET


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
SCRIPT_ROOT = REPOSITORY_ROOT / "Scripts"
CONFIG_PATH = SCRIPT_ROOT / "release-verification-suites.json"
PROJECT_PATH = REPOSITORY_ROOT / "Pokedex.xcodeproj"
SCHEME_ROOT = PROJECT_PATH / "xcshareddata" / "xcschemes"
PIPELINE_MANIFEST = SCRIPT_ROOT / "DataPipeline" / "pipeline-manifest.json"
CRAWLER_PIN = SCRIPT_ROOT / "DataPipeline" / "crawler-source.json"
PACKAGE_LOCK = SCRIPT_ROOT / "DataPipeline" / "Package.resolved"
PIPELINE_RUNNER = SCRIPT_ROOT / "pokedex-data-pipeline"
NETWORK_DENIED_RUNNER = SCRIPT_ROOT / "run-with-network-denied"
NETWORK_DENIED_XCTEST_RUNNER = SCRIPT_ROOT / "run-xctest-bundle-with-network-denied"
DEFAULT_SIMULATOR_DESTINATION = "platform=iOS Simulator,name=iPhone 17,OS=27.0"
XCODE_OFFLINE_FLAGS = [
    "-disableAutomaticPackageResolution",
    "-onlyUsePackageVersionsFromResolvedFile",
    "-skipPackageUpdates",
]
SOURCE_DATABASE_RELATIVE = Path("Modules/PokedexCore/Resources/Database/Pokedex.sqlite")
DATABASE_SIDECARS = ("-wal", "-shm", "-journal")
MANDATORY_SUITE_NAMES = {
    "Modules",
    "PokedexTests",
    "PokedexConcurrencyTests",
    "DatabasePipelineTests",
}


class VerificationError(RuntimeError):
    pass


class GateFailure(RuntimeError):
    def __init__(self, message: str, exit_code: int = 1, failure_kind: str | None = None):
        super().__init__(message)
        self.exit_code = max(1, min(int(exit_code), 255))
        self.failure_kind = failure_kind


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat(timespec="seconds")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def reviewed_input_sparse_roots(source_inputs: list[dict]) -> list[str]:
    """Return pinned crawler checkout directories needed by reviewed inputs."""
    roots = set()
    for item in source_inputs:
        source_path = item.get("path")
        if not isinstance(source_path, str):
            raise VerificationError("Reviewed input has no relative source path")
        path = PurePosixPath(source_path)
        parts = path.parts
        if path.is_absolute() or any(part in {".", ".."} for part in parts):
            raise VerificationError(f"Reviewed input path is not checkout-relative: {source_path}")
        if parts and parts[0] == "Crawlers":
            parts = parts[1:]
            if len(parts) < 2:
                raise VerificationError(f"Reviewed crawler input has no checkout directory: {source_path}")
            roots.add(parts[0])
    if not roots:
        raise VerificationError("Pipeline manifest has no reviewed input directories")
    return sorted(roots)


def atomic_json(path: Path, document: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + f".tmp.{os.getpid()}")
    temporary.write_text(json.dumps(document, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(path)


def normalize_test_identifier(identifier: str) -> str:
    """Normalize Xcode and XCTest names to a stable class/method identity."""
    value = identifier.strip().strip("\"'")
    objc = re.search(r"-\[([^\s\]]+)\s+([^\]]+)\]", value)
    if objc:
        class_name = objc.group(1).split(".")[-1]
        return f"{class_name}/{objc.group(2).split()[0]}"
    value = re.sub(r"\(\)$", "", value)
    parts = [part for part in re.split(r"[/.:]", value) if part and not part.endswith(".xctest")]
    if len(parts) < 2:
        raise VerificationError(f"Cannot normalize test identity: {identifier!r}")
    method = parts[-1]
    if method.startswith("-"):
        method = method[1:]
    return f"{parts[-2].split('.')[-1]}/{method}"


def extract_enumerated_tests(document: object) -> list[str]:
    """Read executable cases from Xcode's compiled JSON enumeration output."""
    if isinstance(document, dict) and document.get("errors"):
        raise VerificationError(f"Xcode compiled test enumeration reported errors: {document['errors']}")
    found: list[str] = []

    def walk(node: object, ancestors: tuple[str, ...] = ()) -> None:
        if isinstance(node, list):
            for child in node:
                walk(child, ancestors)
            return
        if not isinstance(node, dict):
            return
        node_type = node.get("nodeType")
        node_kind = node.get("kind")
        name = node.get("name")
        path = ancestors + ((name,) if isinstance(name, str) and name else ())
        if node_type in {"Test Case", "Test Method", "Test"} or node_kind == "test":
            identity = node.get("nodeIdentifier") or node.get("testIdentifier") or node.get("identifier")
            if not isinstance(identity, str) or not identity:
                if len(path) >= 2:
                    identity = "/".join(path[-2:])
                else:
                    raise VerificationError("Xcode enumeration contains a test case without an identity")
            found.append(normalize_test_identifier(identity))
            return
        for value in node.values():
            if isinstance(value, (dict, list)):
                walk(value, path)

    walk(document)
    if not found:
        raise VerificationError("Xcode compiled test enumeration contains no executable test cases")
    return found


def _mask_non_code(source: str) -> str:
    """Blank Swift comments and string literals while preserving offsets and lines."""
    chars = list(source)
    size = len(source)

    def blank(start: int, end: int) -> None:
        for position in range(start, end):
            if chars[position] not in "\r\n":
                chars[position] = " "

    index = 0
    while index < size:
        if source.startswith("//", index):
            end = source.find("\n", index)
            if end < 0:
                end = size
            blank(index, end)
            index = end
            continue
        if source.startswith("/*", index):
            start = index
            depth = 1
            index += 2
            while index < size and depth:
                if source.startswith("/*", index):
                    depth += 1
                    index += 2
                elif source.startswith("*/", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            blank(start, index)
            continue

        string_start = index
        hash_count = 0
        while index + hash_count < size and source[index + hash_count] == "#":
            hash_count += 1
        quote_index = index + hash_count
        if quote_index < size and source[quote_index] == '"':
            quote_count = 3 if source.startswith('"""', quote_index) else 1
            delimiter = '"' * quote_count + "#" * hash_count
            index = quote_index + quote_count
            while index < size:
                if source.startswith(delimiter, index):
                    index += len(delimiter)
                    break
                if source[index] == "\\":
                    escape_length = 1 + hash_count
                    if index + escape_length < size:
                        index += escape_length + 1
                        continue
                index += 1
            blank(string_start, index)
            continue
        index += 1
    return "".join(chars)


def _source_test_declarations_from_code(code: str) -> list[str]:
    class_pattern = re.compile(r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^\{]+)\{")
    method_pattern = re.compile(r"\bfunc\s+(test[A-Za-z0-9_]+)\s*(?:<[^>]*>\s*)?\(")
    declarations: list[str] = []
    test_classes: set[str] = set()

    def matching_brace(opening: int) -> int:
        depth = 1
        position = opening + 1
        while position < len(code) and depth:
            if code[position] == "{":
                depth += 1
            elif code[position] == "}":
                depth -= 1
            position += 1
        return position - 1

    for match in class_pattern.finditer(code):
        class_name, bases = match.group(1), match.group(2)
        if not re.search(r"\bXCTestCase\b", bases):
            continue
        test_classes.add(class_name)
        opening = code.find("{", match.start(), match.end())
        closing = matching_brace(opening)
        if closing < opening:
            raise VerificationError(f"Unclosed XCTest class body for {class_name}")
        body = code[opening + 1:closing]
        for method in method_pattern.finditer(body):
            method_position = opening + 1 + method.start()
            depth = 0
            for character in code[opening + 1:method_position]:
                if character == "{":
                    depth += 1
                elif character == "}":
                    depth -= 1
            if depth == 0:
                declarations.append(f"{class_name}/{method.group(1)}")

    extension_pattern = re.compile(r"\bextension\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")
    for match in extension_pattern.finditer(code):
        class_name = match.group(1)
        if class_name not in test_classes:
            continue
        opening = code.find("{", match.start(), match.end())
        closing = matching_brace(opening)
        body = code[opening + 1:closing]
        for method in method_pattern.finditer(body):
            method_position = opening + 1 + method.start()
            depth = 0
            for character in code[opening + 1:method_position]:
                if character == "{":
                    depth += 1
                elif character == "}":
                    depth -= 1
            if depth == 0:
                declarations.append(f"{class_name}/{method.group(1)}")
    return sorted(set(declarations))


def _without_conditional_compilation(code: str) -> str:
    """Remove conditional regions so inactive test methods stay optional."""
    chars = list(code)
    directives = re.compile(r"(?m)^[ \t]*#(if|elseif|else|endif)\b[^\r\n]*")
    depth = 0
    start = None
    for match in directives.finditer(code):
        directive = match.group(1)
        if directive == "if":
            if depth == 0:
                start = match.start()
            depth += 1
        elif directive == "endif":
            if depth == 0:
                raise VerificationError("Swift conditional compilation has an unmatched #endif")
            depth -= 1
            if depth == 0 and start is not None:
                for position in range(start, match.end()):
                    if chars[position] not in "\r\n":
                        chars[position] = " "
                start = None
    if depth:
        raise VerificationError("Swift conditional compilation has an unmatched #if")
    return "".join(chars)


def source_test_expectations(source: str) -> tuple[list[str], list[str]]:
    """Separate unconditional tests from conditional source candidates."""
    code = _mask_non_code(source)
    all_declarations = set(_source_test_declarations_from_code(code))
    required = set(_source_test_declarations_from_code(_without_conditional_compilation(code)))
    return sorted(required), sorted(all_declarations - required)


def source_test_declarations(source: str) -> list[str]:
    """Find source candidates; Xcode enumeration remains the executable inventory."""
    required, conditional = source_test_expectations(source)
    return sorted(set(required) | set(conditional))


def reconcile_source_and_enumeration(
    source_tests: list[str],
    enumerated_tests: list[str],
    conditional_source_tests: list[str] | None = None,
) -> dict:
    source_set = set(source_tests)
    conditional_set = set(conditional_source_tests or []) - source_set
    executable_set = set(enumerated_tests)
    duplicates = sorted(
        identifier
        for identifier, count in collections.Counter(enumerated_tests).items()
        if count > 1
    )
    missing = sorted(source_set - executable_set)
    extra = sorted(executable_set - source_set - conditional_set)
    return {
        "sourceDeclarations": sorted(source_set),
        "conditionalSourceCandidates": sorted(conditional_set),
        "compiledEnumeration": sorted(executable_set),
        "sourceDeclarationCount": len(source_set) + len(conditional_set),
        "unconditionalSourceDeclarationCount": len(source_set),
        "conditionalSourceCandidateCount": len(conditional_set),
        "compiledEnumerationCount": len(enumerated_tests),
        "missingFromCompiledEnumeration": missing,
        "extraInCompiledEnumeration": extra,
        "duplicateCompiledIdentities": duplicates,
        "passed": bool(source_set or conditional_set) and not missing and not extra and not duplicates,
    }


def reconcile_results(
    expected: list[str], actual: list[dict], reported_total: int | None
) -> dict:
    """Compare observed case results with the compiled inventory and summary count."""
    expected_counts = collections.Counter(expected)
    actual_counts = collections.Counter(
        entry.get("identifier") for entry in actual if isinstance(entry.get("identifier"), str)
    )
    issues: list[str] = []
    if not expected:
        issues.append("empty")
    if any(count > 1 for count in expected_counts.values()):
        issues.append("duplicate_expected")
    if any(count > 1 for count in actual_counts.values()):
        issues.append("duplicate")
    if expected_counts - actual_counts:
        issues.append("missing")
    if actual_counts - expected_counts:
        issues.append("extra")
    statuses = [str(entry.get("result", "unknown")).lower() for entry in actual]
    if any(status in {"skipped", "skip"} for status in statuses):
        issues.append("skipped")
    if any(status in {"failed", "failure"} for status in statuses):
        issues.append("failed")
    if any(status not in {"passed", "pass", "failed", "failure", "skipped", "skip"} for status in statuses):
        issues.append("unknown_result")
    if reported_total is None or reported_total != len(actual):
        issues.append("incomplete")
    if not actual:
        issues.append("empty")
    counts = {name: statuses.count(name) for name in ("passed", "failed", "skipped")}
    counts["other"] = len(statuses) - sum(counts.values())
    return {
        "passed": not issues,
        "issues": sorted(set(issues)),
        "expectedCount": len(expected),
        "reportedTotal": reported_total,
        "observedCount": len(actual),
        "counts": counts,
        "missing": sorted(expected_counts - actual_counts),
        "extra": sorted(actual_counts - expected_counts),
        "duplicates": sorted(
            identifier for identifier, count in actual_counts.items() if count > 1
        ),
        "cases": actual,
    }


def _result_nodes(document: object) -> list[dict]:
    cases: list[dict] = []

    def walk(node: object, ancestors: tuple[str, ...] = ()) -> None:
        if isinstance(node, list):
            for child in node:
                walk(child, ancestors)
            return
        if not isinstance(node, dict):
            return
        node_type = node.get("nodeType")
        name = node.get("name")
        path = ancestors + ((name,) if isinstance(name, str) and name else ())
        if node_type in {"Test Case", "Test Method", "Test"}:
            identity = node.get("nodeIdentifier") or node.get("testIdentifier") or node.get("identifier")
            if not isinstance(identity, str) or not identity:
                if len(path) < 2:
                    raise VerificationError("Test result contains a case without a stable identity")
                identity = "/".join(path[-2:])
            result = node.get("result")
            if not isinstance(result, str):
                result = "unknown"
            cases.append({"identifier": normalize_test_identifier(identity), "result": result})
            return
        for value in node.values():
            if isinstance(value, (dict, list)):
                walk(value, path)

    walk(document)
    return cases


def _summary_count(document: object, keys: set[str]) -> int | None:
    matches: list[int] = []

    def walk(node: object) -> None:
        if isinstance(node, dict):
            for key, value in node.items():
                if key in keys and isinstance(value, int) and not isinstance(value, bool):
                    matches.append(value)
                if isinstance(value, (dict, list)):
                    walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(document)
    return matches[0] if matches else None


def parse_xctest_log(log_text: str) -> tuple[list[dict], int | None, list[str]]:
    cases: list[dict] = []
    case_pattern = re.compile(
        r"Test Case ['\"](?P<identifier>.*?)['\"]\s+(?P<result>passed|failed|skipped|expected failure)\b",
        re.IGNORECASE,
    )
    for match in case_pattern.finditer(log_text):
        result = match.group("result").lower()
        cases.append(
            {
                "identifier": normalize_test_identifier(match.group("identifier")),
                "result": "Passed" if result == "passed" else "Skipped" if result == "skipped" else "Failed",
            }
        )
    summary_pattern = re.compile(
        r"(?:^|\n)[ \t]*Executed\s+(\d+)\s+tests?,\s+with\s+(\d+)\s+failures?",
        re.IGNORECASE,
    )
    summaries = list(summary_pattern.finditer(log_text))
    issues = []
    all_tests_summary = re.search(
        r"Test Suite ['\"]All tests['\"]\s+(?:passed|failed)\b",
        log_text,
        re.IGNORECASE,
    )
    aggregate_summary = None
    if not summaries:
        issues.append("incomplete")
    elif len(summaries) == 1:
        aggregate_summary = summaries[0]
    elif all_tests_summary and summaries[-1].start() > all_tests_summary.start():
        aggregate_summary = summaries[-1]
    else:
        issues.append("incomplete")
    total = int(aggregate_summary.group(1)) if aggregate_summary else None
    if aggregate_summary:
        if int(aggregate_summary.group(2)) != sum(
            case["result"] == "Failed" for case in cases
        ):
            issues.append("summary_mismatch")
    if total is not None and total != len(cases):
        issues.append("incomplete")
    if not cases or total == 0:
        issues.append("empty")
    return cases, total, sorted(set(issues))


def classify_failure(log_text: str) -> str:
    lowered = log_text.lower()
    if "no space left on device" in lowered or "enospc" in lowered:
        return "disk_exhaustion"
    if any(
        phrase in lowered
        for phrase in (
            "unable to find a destination",
            "no available destinations",
            "simulator device is not available",
            "failed to boot device",
            "unable to boot device",
            "could not boot device",
            "failed to boot simulator",
            "unable to boot simulator",
            "simulator device returned an error",
            "com.apple.coresimulator.simerror",
            "process launch failed:",
            "xcodebuild: error: tool 'xcodebuild' requires xcode",
            "xcode-select: error",
            "unknown option",
            "invalid option",
            "could not resolve host",
            "failed to connect to github.com",
            "network is unreachable",
            "unable to access 'https://github.com/",
        )
    ):
        return "infrastructure_unavailable"
    if "test case" in lowered and (" failed" in lowered or "assertion" in lowered):
        return "test_failure"
    return "gate_failure"


def classify_test_result_failure(log_text: str, report: dict, parse_issues: list[str] | None = None) -> str:
    """Keep explicit disk and infrastructure failures ahead of partial test results."""
    environment_failure = classify_failure(log_text)
    if environment_failure in {"disk_exhaustion", "infrastructure_unavailable"}:
        return environment_failure
    issues = set(report.get("issues", [])) | set(parse_issues or [])
    if "failed" in issues:
        return "test_failure"
    if "skipped" in issues:
        return "unexpected_skip"
    if environment_failure == "test_failure":
        return "test_failure"
    if issues & {"missing", "empty", "incomplete", "unknown_result", "summary_mismatch"}:
        return "incomplete"
    return "inventory_mismatch"


def _load_config(path: Path = CONFIG_PATH) -> dict:
    try:
        document = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise VerificationError(f"Could not load suite configuration {path}: {error}") from error
    required = document.get("requiredSuites")
    suites = document.get("suites")
    if not isinstance(required, list) or not isinstance(suites, list):
        raise VerificationError("Suite configuration requires requiredSuites and suites arrays")
    names = [suite.get("name") for suite in suites if isinstance(suite, dict)]
    if len(names) != len(suites) or len(names) != len(set(names)):
        raise VerificationError("Suite configuration contains malformed or duplicate suite names")
    missing = sorted(MANDATORY_SUITE_NAMES - set(required))
    if missing:
        raise VerificationError(f"Configuration no longer requires the original suites: {missing}")
    missing = sorted(set(required) - set(names))
    if missing:
        raise VerificationError(f"Required test suites are missing from configuration: {missing}")
    return document


def _plist_json(path: Path) -> dict:
    completed = subprocess.run(
        ["/usr/bin/plutil", "-convert", "json", "-o", "-", str(path)],
        capture_output=True,
        text=True,
        check=False,
    )
    if completed.returncode:
        raise VerificationError(f"Could not parse Xcode project: {completed.stderr.strip()}")
    try:
        return json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise VerificationError(f"Xcode project conversion returned invalid JSON: {error}") from error


def _project_file_paths(project_document: dict) -> dict[str, str]:
    objects = project_document.get("objects", {})
    root = objects.get(project_document.get("rootObject"), {})
    main_group = root.get("mainGroup")
    paths: dict[str, str] = {}
    visited: set[tuple[str, str]] = set()

    def visit(identifier: str, parent: str) -> None:
        marker = (identifier, parent)
        if marker in visited:
            return
        visited.add(marker)
        obj = objects.get(identifier, {})
        own = obj.get("path", "")
        current = os.path.normpath(os.path.join(parent, own)) if own else parent
        if obj.get("isa") == "PBXFileReference":
            file_path = obj.get("path") or obj.get("name")
            if isinstance(file_path, str):
                paths[identifier] = os.path.normpath(os.path.join(parent, file_path))
            return
        if obj.get("isa") not in {"PBXGroup", "PBXVariantGroup", "PBXFileSystemSynchronizedRootGroup"}:
            return
        for child in obj.get("children", []):
            visit(child, current)

    if isinstance(main_group, str):
        visit(main_group, "")
    for identifier, obj in objects.items():
        if obj.get("isa") == "PBXFileReference" and identifier not in paths:
            file_path = obj.get("path") or obj.get("name")
            if isinstance(file_path, str):
                paths[identifier] = os.path.normpath(file_path)
    return paths


def verify_scheme_and_target_membership(root: Path, suite: dict) -> dict:
    """Require each scheme to run its configured target and include its test sources."""
    scheme_path = SCHEME_ROOT / f"{suite['scheme']}.xcscheme"
    if not scheme_path.is_file():
        raise VerificationError(f"Shared Xcode scheme is missing: {scheme_path.name}")
    scheme = ET.parse(scheme_path).getroot()
    testables = scheme.findall("./TestAction/Testables/TestableReference")
    active = []
    skipped = []
    for testable in testables:
        reference = testable.find("BuildableReference")
        if reference is None:
            raise VerificationError(f"Scheme {suite['scheme']} has a test reference without a buildable target")
        item = {
            "identifier": reference.get("BlueprintIdentifier"),
            "name": reference.get("BlueprintName"),
            "skipped": testable.get("skipped", "NO").upper() == "YES",
        }
        (skipped if item["skipped"] else active).append(item)
    expected = {"identifier": suite["targetIdentifier"], "name": suite["targetName"], "skipped": False}
    if active != [expected] or skipped:
        raise VerificationError(
            f"Scheme {suite['scheme']} test membership differs from its required target: "
            f"active={active}, skipped={skipped}, required={expected}"
        )

    project = _plist_json(PROJECT_PATH / "project.pbxproj")
    objects = project.get("objects", {})
    target = objects.get(suite["targetIdentifier"])
    if not isinstance(target, dict) or target.get("name") != suite["targetName"]:
        raise VerificationError(f"Project target identity mismatch for {suite['name']}")
    source_file_ids: set[str] = set()
    for phase_id in target.get("buildPhases", []):
        phase = objects.get(phase_id, {})
        if phase.get("isa") != "PBXSourcesBuildPhase":
            continue
        for build_file_id in phase.get("files", []):
            build_file = objects.get(build_file_id, {})
            file_ref = build_file.get("fileRef")
            if isinstance(file_ref, str):
                source_file_ids.add(file_ref)
    file_paths = _project_file_paths(project)
    target_sources = {file_paths[file_ref] for file_ref in source_file_ids if file_ref in file_paths}
    expected_sources: set[str] = set()
    for pattern in suite["sourceGlobs"]:
        expected_sources.update(
            path.relative_to(root).as_posix()
            for path in root.glob(pattern)
            if path.is_file() and path.suffix == ".swift"
        )
    if not expected_sources:
        raise VerificationError(f"No source files matched the configured test files for {suite['name']}")
    missing_membership = sorted(expected_sources - target_sources)
    if missing_membership:
        raise VerificationError(
            f"Configured {suite['name']} test sources are missing from target membership: {missing_membership}"
        )
    source_tests: list[str] = []
    conditional_source_tests: list[str] = []
    for relative_path in sorted(expected_sources):
        required, conditional = source_test_expectations(
            (root / relative_path).read_text(encoding="utf-8")
        )
        source_tests.extend(required)
        conditional_source_tests.extend(conditional)
    if not source_tests and not conditional_source_tests:
        raise VerificationError(f"No XCTest-style test declarations were found for {suite['name']}")
    return {
        "scheme": suite["scheme"],
        "targetName": suite["targetName"],
        "targetIdentifier": suite["targetIdentifier"],
        "sourceFiles": sorted(expected_sources),
        "sourceTests": sorted(set(source_tests)),
        "conditionalSourceTestCandidates": sorted(set(conditional_source_tests)),
    }


def _parse_destination(value: str) -> dict[str, str]:
    parsed: dict[str, str] = {}
    for item in value.split(","):
        if "=" in item:
            key, content = item.split("=", 1)
            parsed[key.strip()] = content.strip()
    return parsed


class VerificationRunner:
    def __init__(self) -> None:
        self.root_input = Path(
            os.environ.get("PIKADEX_RELEASE_BUILD_ROOT", str(REPOSITORY_ROOT / "build" / "release-verification"))
        )
        if not self.root_input.is_absolute():
            self.root_input = (Path.cwd() / self.root_input).absolute()
        self.root = self.root_input
        self.evidence = self.root / "evidence"
        self.work = self.root / "work"
        self.failure_reserve = self.work / ".failure-reserve"
        self.derived_data = self.work / "DerivedData"
        self.pipeline_output = self.work / "PipelineOutput"
        self.crawler_root = self.work / "PikaDexCrawlers"
        self.candidate = self.pipeline_output / "candidate" / "Pokedex.sqlite"
        self.simulator_destination_text = os.environ.get(
            "PIKADEX_SIMULATOR_DESTINATION", DEFAULT_SIMULATOR_DESTINATION
        )
        self.simulator_destination = ""
        self.simulator_info: dict = {}
        self.configuration_error = None
        try:
            self.configuration = _load_config()
        except VerificationError as error:
            self.configuration_error = str(error)
            self.configuration = {"requiredSuites": sorted(MANDATORY_SUITE_NAMES), "suites": []}
        self.suite_records: dict[str, dict] = {}
        self.source_database_snapshot: dict | None = None
        self.initial_lock_sha = ""
        self.initial_workspace_lock = None
        self.gates: dict[str, dict] = {}
        self.first_failure: dict | None = None
        self.manifest: dict = {}
        self.provenance: dict = {}
        self.root_marker = self.root / ".pokedex-release-verification"
        self.gate_names = self._planned_gate_names()

    def _planned_gate_names(self) -> list[str]:
        names = [
            "preflight",
            "crawler_provision",
            "toolchain_capture",
            "package_provision",
            "network_isolation_probe",
            "catalog_verify",
            "candidate_database_binding",
            "pokedex_build",
        ]
        for suite in self.configuration["suites"]:
            key = suite["name"]
            names.append(f"enumerate_{key}")
            if suite["platform"] == "macos":
                names.append(f"build_for_testing_{key}")
            names.append(f"execute_{key}")
        names.extend(["source_database_integrity", "evidence_completeness"])
        return names

    def _write_manifest(self) -> None:
        if not self.evidence.exists():
            return
        self.manifest.update(
            {
                "updatedAt": utc_now(),
                "runState": (
                    "failed"
                    if self.first_failure
                    else "passed"
                    if self.manifest.get("runState") == "passed"
                    else "in_progress"
                ),
                "firstFailure": self.first_failure,
                "gates": self.gates,
                "suites": self.suite_records,
            }
        )
        atomic_json(self.evidence / "manifest.json", self.manifest)

    def _reserve_failure_space(self) -> None:
        """Keep a small writable margin for recording a disk-exhaustion failure."""
        with self.failure_reserve.open("wb") as reserve:
            reserve.write(b"\xa5" * (2 * 1024 * 1024))
            reserve.flush()
            os.fsync(reserve.fileno())

    def _release_failure_reserve(self) -> None:
        try:
            self.failure_reserve.unlink()
        except FileNotFoundError:
            pass

    def _validate_root(self) -> None:
        lexical = self.root_input
        inspected = Path(lexical.anchor)
        for component in lexical.parts[1:]:
            inspected = inspected / component
            if inspected.is_symlink():
                raise VerificationError(f"Verification root contains a symbolic-link component: {inspected}")
        resolved = lexical.resolve(strict=False)
        protected = [Path("/"), Path.home().resolve(), REPOSITORY_ROOT.resolve()]
        for path in protected:
            if resolved == path or path.is_relative_to(resolved):
                if path == REPOSITORY_ROOT.resolve() and resolved.is_relative_to(REPOSITORY_ROOT.resolve() / "build"):
                    continue
                raise VerificationError(f"Verification root overlaps a protected path: {resolved}")
        repository_build = REPOSITORY_ROOT / "build"
        if resolved.is_relative_to(REPOSITORY_ROOT.resolve()) and not resolved.is_relative_to(repository_build.resolve()):
            raise VerificationError("A verification root inside the checkout must be beneath build/")
        if self.root.exists() and not self.root_marker.exists():
            if any(self.root.iterdir()):
                raise VerificationError(f"Existing verification root is not owned by this runner: {self.root}")
        if self.root_marker.is_symlink():
            raise VerificationError(f"Verification root ownership marker cannot be a symbolic link: {self.root_marker}")
        if self.root_marker.exists() and self.root_marker.read_text(encoding="utf-8") != "PikaDex A2 verification runner owns this directory.\n":
            raise VerificationError(f"Verification root ownership marker is invalid: {self.root_marker}")

    def _initialize(self) -> None:
        self._validate_root()
        self.root.mkdir(parents=True, exist_ok=True)
        if self.root_marker.is_symlink():
            raise VerificationError(f"Verification root ownership marker cannot be a symbolic link: {self.root_marker}")
        self.root_marker.write_text("PikaDex A2 verification runner owns this directory.\n", encoding="utf-8")
        for owned in (self.evidence, self.work):
            if owned.is_symlink():
                raise VerificationError(f"Runner-owned path is a symbolic link: {owned}")
            if owned.exists():
                shutil.rmtree(owned)
            owned.mkdir(parents=True)
        self.gates = {
            name: {"status": "not_run", "exitCode": None, "failureKind": None}
            for name in self.gate_names
        }
        for name in self.gate_names:
            (self.evidence / "logs" / f"{name}.log").parent.mkdir(parents=True, exist_ok=True)
            (self.evidence / "logs" / f"{name}.log").touch()
            (self.evidence / "logs" / f"{name}.exit").write_text("not_run\n", encoding="utf-8")
        self.initial_lock_sha = sha256_file(PACKAGE_LOCK)
        workspace_lock = PROJECT_PATH / "project.xcworkspace" / "xcshareddata" / "swiftpm" / "Package.resolved"
        self.initial_workspace_lock = self._lock_snapshot(workspace_lock)
        self.source_database_snapshot = self._snapshot_source_database()
        self.manifest = {
            "schemaVersion": 1,
            "task": "PikaDex Issue #10 A2 CI and local verification parity",
            "startedAt": utc_now(),
            "repository": "danielbyon/PikaDex",
            "repositoryRoot": str(REPOSITORY_ROOT),
            "configuredSimulatorDestination": self.simulator_destination_text,
            "requiredSuites": sorted(self.configuration["requiredSuites"]),
            "suiteConfigurationError": self.configuration_error,
            "artifactRoot": "evidence/",
            "artifactPolicy": [
                "manifest, inventories, full gate logs and statuses, per-suite xcresult bundles, structured XCTest results, provenance, and pipeline validation reports",
                "DerivedData, build products, source copies, and the generated SQLite candidate are excluded",
            ],
        }
        self.provenance = {
            "source": self._source_provenance(),
            "packageLock": {
                "path": "Scripts/DataPipeline/Package.resolved",
                "sha256Before": self.initial_lock_sha,
                "workspaceLockBefore": self.initial_workspace_lock,
            },
            "pipelineManifest": {
                "path": "Scripts/DataPipeline/pipeline-manifest.json",
                "sha256": sha256_file(PIPELINE_MANIFEST),
                "reviewedSourceInputCount": len(json.loads(PIPELINE_MANIFEST.read_text(encoding="utf-8"))["sourceInputs"]),
            },
            "sourceDatabaseBefore": self.source_database_snapshot,
        }
        atomic_json(self.evidence / "provenance.json", self.provenance)
        self._write_manifest()

    def _snapshot_source_database(self) -> dict:
        """Capture database and sidecar content plus metadata before and after the gate."""
        database = REPOSITORY_ROOT / SOURCE_DATABASE_RELATIVE
        result = {}
        for suffix in ("", *DATABASE_SIDECARS):
            path = Path(str(database) + suffix)
            metadata = path.stat() if path.is_file() and not path.is_symlink() else None
            result[path.name] = {
                "present": metadata is not None,
                "sha256": sha256_file(path) if metadata is not None else None,
                "bytes": metadata.st_size if metadata is not None else None,
                "modifiedAtNs": metadata.st_mtime_ns if metadata is not None else None,
                "changedAtNs": metadata.st_ctime_ns if metadata is not None else None,
                "inode": metadata.st_ino if metadata is not None else None,
                "mode": stat.S_IMODE(metadata.st_mode) if metadata is not None else None,
                "symlink": path.is_symlink(),
            }
        return result

    @staticmethod
    def _lock_snapshot(path: Path) -> dict:
        if path.is_symlink():
            return {"state": "symlink"}
        if not path.is_file():
            return {"state": "absent"}
        return {"state": "file", "sha256": sha256_file(path), "bytes": path.stat().st_size}

    def _source_provenance(self) -> dict:
        def git(args: list[str]) -> str:
            result = subprocess.run(
                ["/usr/bin/git", "-C", str(REPOSITORY_ROOT), *args],
                capture_output=True,
                text=True,
                check=False,
            )
            if result.returncode:
                raise VerificationError(f"Could not record source provenance: {result.stderr.strip()}")
            return result.stdout

        status = git(["status", "--porcelain", "--untracked-files=all"])
        changed_paths = []
        for line in status.splitlines():
            relative = line[3:]
            path = REPOSITORY_ROOT / relative
            entry = {"status": line[:2], "path": relative}
            if path.is_file() and not path.is_symlink():
                entry["sha256"] = sha256_file(path)
            changed_paths.append(entry)
        return {
            "head": git(["rev-parse", "HEAD"]).strip(),
            "branch": git(["branch", "--show-current"]).strip(),
            "workingTreeClean": not bool(status),
            "changedPaths": changed_paths,
            "statusSha256": hashlib.sha256(status.encode("utf-8")).hexdigest(),
        }

    def _run_process(self, args: list[str], log_path: Path, env: dict | None = None) -> int:
        log_path.parent.mkdir(parents=True, exist_ok=True)
        with log_path.open("ab") as log:
            log.write(("$ " + " ".join(args) + "\n").encode("utf-8", errors="replace"))
            log.flush()
            try:
                process = subprocess.Popen(
                    args,
                    cwd=REPOSITORY_ROOT,
                    env=env,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    errors="replace",
                    bufsize=1,
                )
            except OSError as error:
                log.write(f"process launch failed: {error}\n".encode())
                return 127
            assert process.stdout is not None
            try:
                for line in process.stdout:
                    log.write(line.encode("utf-8", errors="replace"))
                    if re.search(r"(^|\s)(error:|warning:)|Test (Suite|Case)|Executed \d+ tests|BUILD (SUCCEEDED|FAILED)|TEST (SUCCEEDED|FAILED)", line, re.IGNORECASE):
                        print(line.rstrip(), flush=True)
            except OSError:
                try:
                    process.stdout.close()
                except OSError:
                    pass
                try:
                    if process.poll() is None:
                        process.terminate()
                except OSError:
                    pass
                try:
                    process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    try:
                        process.kill()
                    except OSError:
                        pass
                    process.wait()
                raise
            return process.wait()

    def _gate(self, name: str, action) -> bool:
        record = self.gates[name]
        log_path = self.evidence / "logs" / f"{name}.log"
        print(f"Gate started: {name}", flush=True)
        try:
            if name == "preflight":
                self._reserve_failure_space()
            record["status"] = "running"
            record["startedAt"] = utc_now()
            (self.evidence / "logs" / f"{name}.exit").write_text("in_progress\n", encoding="utf-8")
            self._write_manifest()
            code = action(log_path)
            if code not in (None, 0):
                text = log_path.read_text(encoding="utf-8", errors="replace")
                raise GateFailure(f"{name} exited with status {code}", code, classify_failure(text))
            record["status"] = "passed"
            record["exitCode"] = 0
            (self.evidence / "logs" / f"{name}.exit").write_text("0\n", encoding="utf-8")
            print(f"Gate passed: {name}", flush=True)
            return True
        except GateFailure as error:
            failure_kind = error.failure_kind or classify_failure(
                log_path.read_text(encoding="utf-8", errors="replace")
            )
            if failure_kind == "disk_exhaustion":
                self._release_failure_reserve()
            with log_path.open("a", encoding="utf-8") as output:
                output.write(f"\nRUNNER FAILURE: {error}\n")
            record["status"] = "failed"
            record["exitCode"] = error.exit_code
            record["failureKind"] = failure_kind
            record["failure"] = str(error)
            (self.evidence / "logs" / f"{name}.exit").write_text(
                f"{error.exit_code}\n", encoding="utf-8"
            )
            if self.first_failure is None:
                self.first_failure = {
                    "gate": name,
                    "exitCode": error.exit_code,
                    "failureKind": record["failureKind"],
                    "message": str(error),
                }
            print(f"Gate failed: {name} ({record['failureKind']}, exit {error.exit_code})", flush=True)
            return False
        except VerificationError as error:
            with log_path.open("a", encoding="utf-8") as output:
                output.write(f"\nVERIFICATION ERROR: {error}\n")
            record["status"] = "failed"
            record["exitCode"] = 2
            record["failureKind"] = "incomplete"
            record["failure"] = str(error)
            (self.evidence / "logs" / f"{name}.exit").write_text("2\n", encoding="utf-8")
            if self.first_failure is None:
                self.first_failure = {
                    "gate": name,
                    "exitCode": 2,
                    "failureKind": "incomplete",
                    "message": str(error),
                }
            print(f"Gate failed: {name} (incomplete, exit 2)", flush=True)
            return False
        except Exception as error:  # evidence must survive unexpected runner errors
            disk_full = isinstance(error, OSError) and error.errno == errno.ENOSPC
            if disk_full:
                self._release_failure_reserve()
            with log_path.open("a", encoding="utf-8") as output:
                output.write(f"\nRUNNER ERROR: {type(error).__name__}: {error}\n")
            record["status"] = "failed"
            record["exitCode"] = errno.ENOSPC if disk_full else 2
            record["failureKind"] = "disk_exhaustion" if disk_full else "runner_error"
            record["failure"] = f"{type(error).__name__}: {error}"
            (self.evidence / "logs" / f"{name}.exit").write_text(f"{record['exitCode']}\n", encoding="utf-8")
            if self.first_failure is None:
                self.first_failure = {
                    "gate": name,
                    "exitCode": record["exitCode"],
                    "failureKind": record["failureKind"],
                    "message": record["failure"],
                }
            print(f"Gate failed: {name} ({record['failureKind']}): {error}", flush=True)
            return False
        finally:
            record["finishedAt"] = utc_now()
            self._write_manifest()

    def _require_process(self, args: list[str], log: Path, env: dict | None = None) -> None:
        code = self._run_process(args, log, env)
        if code:
            raise GateFailure(f"Command failed with exit status {code}: {args[0]}", code)

    def _preflight(self, log: Path) -> None:
        self._validate_root()
        if self.configuration_error:
            raise GateFailure(self.configuration_error, 2, "suite_configuration")
        for executable in ("/usr/bin/xcodebuild", "/usr/bin/xcrun", "/usr/bin/sandbox-exec", "/usr/bin/git"):
            if not Path(executable).is_file():
                raise GateFailure(f"Required macOS verification tool is missing: {executable}", 2, "infrastructure_unavailable")
        for helper in (PIPELINE_RUNNER, NETWORK_DENIED_RUNNER, NETWORK_DENIED_XCTEST_RUNNER):
            if not helper.is_file() or not os.access(helper, os.X_OK):
                raise GateFailure(f"Required verification helper is missing or not executable: {helper}", 2)
        try:
            self._resolve_simulator(log)
        except VerificationError as error:
            raise GateFailure(str(error), 2, "infrastructure_unavailable") from error
        for suite in self.configuration["suites"]:
            self.suite_records[suite["name"]] = verify_scheme_and_target_membership(REPOSITORY_ROOT, suite)

    def _resolve_simulator(self, log: Path) -> None:
        requested = _parse_destination(self.simulator_destination_text)
        if requested.get("platform") != "iOS Simulator":
            raise VerificationError("The simulator destination must use platform=iOS Simulator")
        result = subprocess.run(
            ["/usr/bin/xcrun", "simctl", "list", "devices", "available", "--json"],
            capture_output=True,
            text=True,
            check=False,
        )
        log.write_text(result.stdout + result.stderr, encoding="utf-8")
        if result.returncode:
            raise VerificationError(f"Unable to list available iOS simulators: {result.stderr.strip()}")
        try:
            document = json.loads(result.stdout)
        except json.JSONDecodeError as error:
            raise VerificationError(f"Simulator inventory is invalid JSON: {error}") from error
        devices = []
        for runtime, runtime_devices in document.get("devices", {}).items():
            if "iOS" not in runtime:
                continue
            for device in runtime_devices:
                if device.get("isAvailable", True):
                    devices.append((runtime, device))
        candidates = []
        for runtime, device in devices:
            if requested.get("id") and device.get("udid") != requested["id"]:
                continue
            if requested.get("name") and device.get("name") != requested["name"]:
                continue
            if requested.get("OS"):
                normalized = requested["OS"].replace(".", "-")
                if not runtime.endswith(normalized) and runtime.split(".")[-1] != requested["OS"]:
                    runtime_digits = runtime.rsplit("iOS-", 1)[-1].replace("-", ".")
                    if runtime_digits != requested["OS"]:
                        continue
            candidates.append((runtime, device))
        if len(candidates) != 1:
            raise VerificationError(
                f"Simulator destination resolved to {len(candidates)} available devices: {self.simulator_destination_text}"
            )
        runtime, device = candidates[0]
        self.simulator_destination = f"platform=iOS Simulator,id={device['udid']}"
        self.simulator_info = {
            "name": device.get("name"),
            "identifier": device.get("udid"),
            "runtime": runtime,
            "deviceTypeIdentifier": device.get("deviceTypeIdentifier"),
        }

    def _provision_crawler(self, log: Path) -> None:
        pin = json.loads(CRAWLER_PIN.read_text(encoding="utf-8"))
        repository, revision = pin.get("repository"), pin.get("revision")
        if repository != "danielbyon/PikaDexCrawlers" or not re.fullmatch(r"[0-9a-f]{40}", str(revision)):
            raise GateFailure("Crawler source pin is invalid", 2)
        manifest = json.loads(PIPELINE_MANIFEST.read_text(encoding="utf-8"))
        source_inputs = manifest.get("sourceInputs", [])
        sparse_roots = reviewed_input_sparse_roots(source_inputs)
        self.crawler_root.parent.mkdir(parents=True, exist_ok=True)
        if self.crawler_root.exists():
            shutil.rmtree(self.crawler_root)
        self.crawler_root.mkdir()
        git_env = os.environ.copy()
        git_env.update(
            {
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_GLOBAL": "/dev/null",
                "GIT_TERMINAL_PROMPT": "0",
            }
        )
        commands = [
            ["/usr/bin/git", "init"],
            ["/usr/bin/git", "remote", "add", "origin", f"https://github.com/{repository}.git"],
            ["/usr/bin/git", "config", "remote.origin.promisor", "true"],
            ["/usr/bin/git", "config", "remote.origin.partialclonefilter", "blob:none"],
            ["/usr/bin/git", "config", "credential.helper", ""],
            ["/usr/bin/git", "sparse-checkout", "init", "--cone"],
            ["/usr/bin/git", "sparse-checkout", "set", *sparse_roots],
            ["/usr/bin/git", "fetch", "--no-tags", "--filter=blob:none", "--depth=1", "origin", revision],
            ["/usr/bin/git", "checkout", "--detach", revision],
        ]
        for command in commands:
            # Git commands run in the isolated crawler checkout, with network enabled only here.
            with log.open("ab") as output:
                output.write(("$ " + " ".join(command) + "\n").encode())
                completed = subprocess.run(
                    command,
                    cwd=self.crawler_root,
                    env=git_env,
                    stdout=output,
                    stderr=subprocess.STDOUT,
                    check=False,
                )
            if completed.returncode:
                raise GateFailure(f"Crawler provisioning command failed: {command[1]}", completed.returncode)
        resolved = subprocess.run(
            ["/usr/bin/git", "-C", str(self.crawler_root), "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            check=False,
        )
        actual_revision = resolved.stdout.strip()
        if resolved.returncode or actual_revision != revision or any(
            not (self.crawler_root / root).is_dir() for root in sparse_roots
        ):
            raise GateFailure("Provisioned crawler checkout does not match the pinned source revision", 2)
        self.provenance["crawler"] = {
            "repository": repository,
            "revisionExpected": revision,
            "revisionObserved": actual_revision,
            "checkoutRelativeToWorkRoot": "PikaDexCrawlers",
            "sparseCheckoutRoots": sparse_roots,
            "networkProvisioning": "permitted; exact detached commit and manifest-derived sparse checkout",
        }
        reviewed_inputs = []
        for item in source_inputs:
            source_path = str(item["path"])
            if source_path.startswith("Crawlers/"):
                path = self.crawler_root / source_path[len("Crawlers/"):]
                source_repository = repository
                source_revision = actual_revision
            else:
                path = REPOSITORY_ROOT / source_path
                source_repository = "danielbyon/PikaDex"
                source_revision = self.provenance["source"]["head"]
            if not path.is_file():
                raise GateFailure(f"Reviewed source input is missing: {item['path']}", 2)
            observed_hash = sha256_file(path)
            if observed_hash != item.get("sha256"):
                raise GateFailure(f"Reviewed source input hash mismatch: {item['path']}", 2)
            reviewed_inputs.append({
                "path": item["path"],
                "sha256": observed_hash,
                "sourceRepository": source_repository,
                "sourceRevision": source_revision,
            })
        if len(reviewed_inputs) != 69:
            raise GateFailure(f"Expected 69 reviewed source inputs, observed {len(reviewed_inputs)}", 2)
        self.provenance["reviewedInputs"] = {
            "count": len(reviewed_inputs),
            "manifestSha256": sha256_file(PIPELINE_MANIFEST),
            "inputs": reviewed_inputs,
        }
        atomic_json(self.evidence / "provenance.json", self.provenance)

    def _capture_toolchain(self, log: Path) -> None:
        commands = {
            "xcode": ["/usr/bin/xcodebuild", "-version"],
            "swift": ["/usr/bin/swift", "--version"],
            "iOSSimulatorSDK": ["/usr/bin/xcrun", "--sdk", "iphonesimulator", "--show-sdk-version"],
            "macOSSDK": ["/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-version"],
            "macOS": ["/usr/bin/sw_vers", "-productVersion"],
            "architecture": ["/usr/bin/uname", "-m"],
        }
        values = {}
        for name, command in commands.items():
            result = subprocess.run(command, capture_output=True, text=True, check=False)
            with log.open("a", encoding="utf-8") as output:
                output.write("$ " + " ".join(command) + "\n")
                output.write(result.stdout)
                output.write(result.stderr)
            if result.returncode:
                raise GateFailure(f"Could not record {name} toolchain version", result.returncode)
            values[name] = result.stdout.strip()
        values["simulator"] = self.simulator_info
        atomic_json(self.evidence / "toolchain.json", values)
        self.provenance["toolchainPath"] = "toolchain.json"
        self._write_manifest()

    def _package_provision(self, log: Path) -> None:
        env = os.environ.copy()
        env.update(
            {
                "PIKADEX_PIPELINE_BUILD_ROOT": str(self.work),
                "PIKADEX_CRAWLERS_ROOT": str(self.crawler_root),
            }
        )
        self._require_process([str(PIPELINE_RUNNER), "prepare-tools"], log, env)
        workspace_lock = PROJECT_PATH / "project.xcworkspace" / "xcshareddata" / "swiftpm" / "Package.resolved"
        if not workspace_lock.is_file() or sha256_file(workspace_lock) != self.initial_lock_sha:
            raise GateFailure("Xcode package lock is missing or differs from the pinned lock after provisioning", 2)
        self.provenance["packageLock"].update(
            {"workspaceLockSha256": sha256_file(workspace_lock), "resolution": "pinned lock only"}
        )
        atomic_json(self.evidence / "provenance.json", self.provenance)

    def _network_probe(self, log: Path) -> None:
        probe = (
            "import errno,socket,sys; s=socket.socket(); "
            "\ntry: s.connect(('127.0.0.1',9))\n"
            "except OSError as e: sys.exit(0 if e.errno==errno.EPERM else 3)\n"
            "else: sys.exit(4)"
        )
        code = self._run_process([str(NETWORK_DENIED_RUNNER), "/usr/bin/python3", "-c", probe], log)
        if code:
            raise GateFailure(
                "Network-denial probe did not receive EPERM from a loopback connection attempt",
                code,
                "network_isolation_failure",
            )
        with log.open("a", encoding="utf-8") as output:
            output.write("Network-denial probe received EPERM from a loopback connection attempt.\n")
        self.provenance["networkBoundaries"] = {
            "crawlerCheckout": "network permitted for pinned provisioning only",
            "SwiftPackageProvisioning": "network permitted during prepare-tools; versions constrained by the canonical Package.resolved",
            "catalogVerify": "run through Scripts/run-with-network-denied",
            "DatabasePipelineTests": "Xcode enumeration/build use pinned package resolution; the actual xctest process runs through run-xctest-bundle-with-network-denied",
            "sandboxProbe": "loopback connect denied with EPERM",
            "simulatorSuites": "xcodebuild package resolution disabled; simulator runtime remains managed by CoreSimulator",
        }
        atomic_json(self.evidence / "provenance.json", self.provenance)

    def _catalog_verify(self, log: Path) -> None:
        env = os.environ.copy()
        env.update(
            {
                "PIKADEX_PIPELINE_BUILD_ROOT": str(self.work),
                "PIKADEX_CRAWLERS_ROOT": str(self.crawler_root),
            }
        )
        code = self._run_process(
            [str(PIPELINE_RUNNER), "verify", "--output-dir", str(self.pipeline_output)], log, env
        )
        self.provenance["pipelineReports"] = self._collect_pipeline_reports()
        atomic_json(self.evidence / "provenance.json", self.provenance)
        if code:
            raise GateFailure(
                f"Offline catalog verification exited with status {code}",
                code,
                classify_failure(log.read_text(encoding="utf-8", errors="replace")),
            )
        required_reports = {"preflight.json", "preflight.txt", "validation.json", "validation.txt"}
        observed_reports = {Path(report).name for report in self.provenance["pipelineReports"]}
        if required_reports - observed_reports:
            raise GateFailure(
                f"Catalog verification did not produce all expected validation reports: {sorted(required_reports - observed_reports)}",
                2,
                "incomplete",
            )
        if not self.candidate.is_file() or self.candidate.is_symlink() or self.candidate.stat().st_size == 0:
            raise GateFailure("Offline catalog verification did not produce a nonempty candidate database", 2)
        self.provenance["candidateDatabase"] = {
            "pathRelativeToWorkRoot": "PipelineOutput/candidate/Pokedex.sqlite",
            "sha256": sha256_file(self.candidate),
            "bytes": self.candidate.stat().st_size,
            "generationMode": "verify; candidate not installed",
        }
        atomic_json(self.evidence / "provenance.json", self.provenance)

    def _collect_pipeline_reports(self) -> list[str]:
        report_root = self.evidence / "reports" / "pipeline"
        reports: list[str] = []
        for name in ("preflight.json", "preflight.txt", "validation.json", "validation.txt"):
            path = self.pipeline_output / "reports" / name
            if not path.is_file() or path.is_symlink():
                continue
            destination = report_root / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, destination)
            reports.append(destination.relative_to(self.evidence).as_posix())
        return reports

    def _verify_candidate_binding(self, log: Path) -> None:
        candidate_hash = self._require_validated_candidate_hash()
        self.provenance["candidateDatabase"]["bindingSha256"] = candidate_hash
        source_now = self._snapshot_source_database()
        if source_now != self.source_database_snapshot:
            raise GateFailure("Catalog verification changed the checkout source database or sidecars", 2)
        self.provenance["sourceDatabaseAfterCatalogVerify"] = source_now
        atomic_json(self.evidence / "provenance.json", self.provenance)
        with log.open("a", encoding="utf-8") as output:
            output.write(f"candidate sha256: {candidate_hash}\n")
            output.write("source database and sidecars unchanged after verify\n")

    def _require_validated_candidate_hash(self) -> str:
        """Reject candidate changes after offline validation established its digest."""
        record = self.provenance.get("candidateDatabase", {})
        validated_hash = record.get("sha256")
        if not isinstance(validated_hash, str) or not re.fullmatch(r"[0-9a-f]{64}", validated_hash):
            raise GateFailure("Validated candidate database hash is missing or invalid", 2, "incomplete")
        if not self.candidate.is_file() or self.candidate.is_symlink():
            raise GateFailure("Candidate database disappeared before build binding", 2, "incomplete")
        observed_hash = sha256_file(self.candidate)
        if observed_hash != validated_hash:
            raise GateFailure("Candidate database changed after offline catalog validation", 2, "candidate_binding")
        return validated_hash

    def _xcode_build_args(self, scheme: str, destination: str, action: str) -> list[str]:
        return [
            "/usr/bin/xcodebuild",
            action,
            "-project",
            str(PROJECT_PATH),
            "-scheme",
            scheme,
            "-destination",
            destination,
            *XCODE_OFFLINE_FLAGS,
            "-derivedDataPath",
            str(self.derived_data),
            "-parallel-testing-enabled",
            "NO",
            "CODE_SIGNING_ALLOWED=NO",
            f"PIKADEX_GENERATED_DATABASE_PATH={self.candidate}",
        ]

    def _app_build(self, log: Path) -> None:
        args = self._xcode_build_args("Pokedex", "generic/platform=iOS Simulator", "build")
        self._require_process(args, log)
        self._verify_packaged_candidate(log, "ios-simulator", require_app_bundle=True)

    def _verify_packaged_candidate(
        self, log: Path, platform: str, require_app_bundle: bool = False
    ) -> None:
        """Require every built framework resource for this platform to match the candidate."""
        products = self.derived_data / "Build" / "Products"
        matches = sorted(
            path
            for path in products.rglob("Pokedex.sqlite")
            if path.is_file()
            and not path.is_symlink()
            and any(parent.name == "PokedexCore.framework" for parent in path.parents)
        ) if products.exists() else []
        expected_products = []
        for resource in matches:
            product_path = resource.relative_to(products)
            configuration = product_path.parts[0].lower()
            if platform == "ios-simulator" and "iphonesimulator" in configuration:
                expected_products.append(resource)
            elif platform == "macos" and "iphone" not in configuration:
                expected_products.append(resource)
        if not expected_products:
            raise GateFailure(f"No packaged PokedexCore.sqlite resource was built for {platform}", 2)
        if require_app_bundle and not any(
            any(part.endswith(".app") for part in resource.relative_to(products).parts)
            and any(parent.name == "PokedexCore.framework" for parent in resource.parents)
            for resource in expected_products
        ):
            raise GateFailure("Pokedex.app does not contain the bundled PokedexCore.sqlite resource", 2)
        candidate_hash = self._require_validated_candidate_hash()
        observed = []
        for resource in expected_products:
            value = sha256_file(resource)
            observed.append({
                "productPath": resource.relative_to(self.derived_data).as_posix(),
                "sha256": value,
                "matchesCandidate": value == candidate_hash,
            })
        if not all(item["matchesCandidate"] for item in observed):
            raise GateFailure(f"A packaged PokedexCore.sqlite resource differs from the verified candidate for {platform}", 2)
        catalog_records = {
            item["productPath"]: item
            for item in self.provenance.get("packagedCatalogs", [])
        }
        for item in observed:
            previous = catalog_records.get(item["productPath"], {})
            platforms = set(previous.get("verifiedFor", []))
            platforms.add(platform)
            catalog_records[item["productPath"]] = {
                **item,
                "verifiedFor": sorted(platforms),
            }
        self.provenance["packagedCatalogs"] = [catalog_records[key] for key in sorted(catalog_records)]
        atomic_json(self.evidence / "provenance.json", self.provenance)
        with log.open("a", encoding="utf-8") as output:
            output.write(json.dumps(observed, indent=2) + "\n")

    def _enumerate_suite(self, suite: dict, log: Path) -> None:
        name = suite["name"]
        if suite["platform"] == "ios-simulator":
            destination = self.simulator_destination
        else:
            destination = "platform=macOS,arch=arm64"
        output_path = self.evidence / "inventory" / f"{name}-enumeration.json"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        args = self._xcode_build_args(suite["scheme"], destination, "test") + [
            "-enumerate-tests",
            "-test-enumeration-style",
            "hierarchical",
            "-test-enumeration-format",
            "json",
            "-test-enumeration-output-path",
            str(output_path),
        ]
        self._require_process(args, log)
        try:
            raw = json.loads(output_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise GateFailure(f"Xcode did not produce valid compiled test enumeration JSON for {name}: {error}", 2)
        executable = extract_enumerated_tests(raw)
        declared = self.suite_records[name]["sourceTests"]
        reconciliation = reconcile_source_and_enumeration(
            declared,
            executable,
            self.suite_records[name].get("conditionalSourceTestCandidates", []),
        )
        inventory = {
            "suite": name,
            "scheme": suite["scheme"],
            "targetName": suite["targetName"],
            "targetIdentifier": suite["targetIdentifier"],
            "platform": suite["platform"],
            "simulator": self.simulator_info if suite["platform"] == "ios-simulator" else None,
            "sourceExpectationIsReconciliationOnly": True,
            "executableIdentitySource": "xcodebuild -enumerate-tests -test-enumeration-format json",
            "sourceDeclarationCount": reconciliation["sourceDeclarationCount"],
            "compiledExecutableCount": len(executable),
            "compiledExecutableTests": sorted(executable),
            "sourceReconciliation": reconciliation,
        }
        atomic_json(self.evidence / "inventory" / f"{name}.json", inventory)
        self.suite_records[name].update(inventory)
        if not reconciliation["passed"]:
            raise GateFailure(
                f"Compiled Xcode inventory does not match source expectations for {name}",
                2,
                "inventory_mismatch",
            )
        if suite["platform"] == "ios-simulator":
            self._verify_packaged_candidate(log, suite["platform"])
        atomic_json(self.evidence / "provenance.json", self.provenance)
        self._write_manifest()

    def _build_for_testing(self, suite: dict, log: Path) -> None:
        self._require_process(
            self._xcode_build_args(suite["scheme"], "platform=macOS,arch=arm64", "build-for-testing"),
            log,
        )
        self._verify_packaged_candidate(log, suite["platform"])

    def _execute_suite(self, suite: dict, log: Path) -> None:
        """Run one suite and retain structured results, including partial failures."""
        name = suite["name"]
        inventory = self.suite_records[name]
        expected = inventory.get("compiledExecutableTests", [])
        if suite["platform"] == "ios-simulator":
            result_bundle = self.evidence / "results" / f"{name}.xcresult"
            result_bundle.parent.mkdir(parents=True, exist_ok=True)
            args = self._xcode_build_args(suite["scheme"], self.simulator_destination, "test") + [
                "-resultBundlePath",
                str(result_bundle),
                "-collect-test-diagnostics",
                "never",
            ]
            inventory["executionStarted"] = True
            self._write_manifest()
            code = self._run_process(args, log)
            log_text = log.read_text(encoding="utf-8", errors="replace")
            tests_json = self._export_xcresult(result_bundle, "tests", name, log)
            summary_json = self._export_xcresult(result_bundle, "summary", name, log)
            parse_issues = []
            fallback_notes = []
            cases = None
            if tests_json is not None:
                try:
                    cases = _result_nodes(tests_json)
                except VerificationError as error:
                    parse_issues.append(f"xcresult tests: {error}")
            cases_from_xcresult = bool(cases)
            reported_total = (
                _summary_count(
                    summary_json,
                    {"totalTestCount", "totalTests", "testCount", "executedTests"},
                )
                if summary_json is not None
                else None
            )
            total_from_xcresult = reported_total is not None
            log_cases, log_total, log_parse_issues = parse_xctest_log(log_text)
            if not cases:
                cases = log_cases
                fallback_notes.append("Test case results were read from the full xcodebuild log.")
                if not log_cases:
                    parse_issues.extend(log_parse_issues)
            if reported_total is None:
                reported_total = log_total
                fallback_notes.append("The executed test count was read from the full xcodebuild log.")
                if log_total is None:
                    parse_issues.extend(log_parse_issues)
            report = reconcile_results(expected, cases, reported_total)
            report["logParseIssues"] = parse_issues
            structured = {
                "suite": name,
                "resultSource": "xcresult" if cases_from_xcresult and total_from_xcresult else "mixed" if cases_from_xcresult or total_from_xcresult else "xcodebuild-log",
                "caseIdentitySource": "xcresult" if cases_from_xcresult else "xcodebuild-log",
                "reportedTotalSource": "xcresult" if total_from_xcresult else "xcodebuild-log",
                "xcodebuildExitCode": code,
                "xcresultBundleAvailable": result_bundle.is_dir(),
                "xcresultTestsExported": tests_json is not None,
                "xcresultSummaryExported": summary_json is not None,
                "fallbackNotes": fallback_notes,
                "verification": report,
            }
            atomic_json(self.evidence / "results" / f"{name}-structured-results.json", structured)
            inventory["resultVerification"] = structured
            self._write_manifest()
            if code or not report["passed"]:
                issue_kind = classify_test_result_failure(log_text, report, parse_issues)
                if code and report["passed"] and issue_kind == "inventory_mismatch":
                    issue_kind = "incomplete"
                raise GateFailure(
                    f"{name} results do not reconcile with its compiled inventory: {report['issues'] + parse_issues}",
                    code or 1,
                    issue_kind,
                )
        else:
            bundle = self.derived_data / "Build" / "Products" / "Debug" / "DatabasePipelineTests.xctest"
            if not bundle.exists():
                raise GateFailure("DatabasePipelineTests.xctest bundle is missing after build-for-testing", 2, "incomplete")
            test_log = self.evidence / "logs" / f"{name}-xctest.log"
            environment = os.environ.copy()
            profile_directory = self.work / "Profiles"
            profile_directory.mkdir(parents=True, exist_ok=True)
            environment["LLVM_PROFILE_FILE"] = str(profile_directory / f"{name}-%p.profraw")
            inventory["executionStarted"] = True
            inventory["networkIsolation"] = str(NETWORK_DENIED_XCTEST_RUNNER.relative_to(REPOSITORY_ROOT))
            self._write_manifest()
            code = self._run_process([str(NETWORK_DENIED_XCTEST_RUNNER), str(bundle)], test_log, environment)
            text = test_log.read_text(encoding="utf-8", errors="replace")
            cases, reported_total, parse_issues = parse_xctest_log(text)
            report = reconcile_results(expected, cases, reported_total)
            report["logParseIssues"] = parse_issues
            structured = {
                "suite": name,
                "resultSource": "xctest-log",
                "xctestExitCode": code,
                "networkIsolation": "run-xctest-bundle-with-network-denied -> run-with-network-denied -> sandbox-exec",
                "verification": report,
            }
            atomic_json(self.evidence / "results" / f"{name}-structured-results.json", structured)
            inventory["resultVerification"] = structured
            self._write_manifest()
            if code or not report["passed"]:
                issue = classify_test_result_failure(text, report, parse_issues)
                if code and report["passed"] and issue == "inventory_mismatch":
                    issue = "incomplete"
                raise GateFailure(
                    f"Network-isolated XCTest result did not reconcile for {name}: {report['issues'] + parse_issues}",
                    code or 1,
                    issue,
                )
            self.suite_records[name]["resultVerification"] = report
        atomic_json(self.evidence / "provenance.json", self.provenance)
        self._write_manifest()

    def _export_xcresult(self, bundle: Path, kind: str, suite_name: str, log: Path) -> object | None:
        if not bundle.is_dir():
            return None
        destination = self.evidence / "results" / f"{suite_name}-{kind}.json"
        args = ["/usr/bin/xcrun", "xcresulttool", "get", "test-results", kind, "--path", str(bundle), "--compact"]
        try:
            result = subprocess.run(args, capture_output=True, text=True, check=False)
        except OSError as error:
            try:
                with log.open("a", encoding="utf-8") as output:
                    output.write("$ " + " ".join(args) + "\n")
                    output.write(f"xcresult export could not start: {error}\n")
            except OSError:
                pass
            return None
        with log.open("a", encoding="utf-8") as output:
            output.write("$ " + " ".join(args) + "\n")
            output.write(result.stdout)
            output.write(result.stderr)
        if result.returncode:
            return None
        try:
            document = json.loads(result.stdout)
        except json.JSONDecodeError:
            return None
        atomic_json(destination, document)
        return document

    def _source_database_integrity(self, log: Path) -> None:
        current = self._snapshot_source_database()
        lock_after = sha256_file(PACKAGE_LOCK)
        workspace_lock = PROJECT_PATH / "project.xcworkspace" / "xcshareddata" / "swiftpm" / "Package.resolved"
        workspace_lock_after = self._lock_snapshot(workspace_lock)
        self.provenance["sourceDatabaseAfterRun"] = current
        self.provenance["packageLock"]["sha256After"] = lock_after
        self.provenance["packageLock"]["workspaceLockAfter"] = workspace_lock_after
        atomic_json(self.evidence / "provenance.json", self.provenance)
        with log.open("a", encoding="utf-8") as output:
            output.write(json.dumps({"before": self.source_database_snapshot, "after": current}, indent=2) + "\n")
            output.write(f"Package.resolved sha256 after run: {lock_after}\n")
            output.write(f"Workspace Package.resolved after run: {workspace_lock_after}\n")
        if current != self.source_database_snapshot:
            raise GateFailure("Verification modified the checkout database or a SQLite sidecar", 2)
        if lock_after != self.initial_lock_sha:
            raise GateFailure("Verification modified Scripts/DataPipeline/Package.resolved", 2)
        if (
            self.gates.get("package_provision", {}).get("status") == "passed"
            and workspace_lock_after != {"state": "file", "sha256": self.initial_lock_sha, "bytes": PACKAGE_LOCK.stat().st_size}
        ):
            raise GateFailure("Xcode changed the workspace package lock after pinned provisioning", 2)

    def _evidence_completeness(self, log: Path) -> None:
        missing = []
        for required in ("manifest.json", "provenance.json"):
            if not (self.evidence / required).is_file():
                missing.append(required)
        for gate_name in self.gate_names:
            if not (self.evidence / "logs" / f"{gate_name}.log").is_file():
                missing.append(f"logs/{gate_name}.log")
            if not (self.evidence / "logs" / f"{gate_name}.exit").is_file():
                missing.append(f"logs/{gate_name}.exit")
        if not (self.evidence / "toolchain.json").is_file():
            missing.append("toolchain.json")
        if not (self.evidence / "provenance.json").is_file():
            missing.append("provenance.json")
        for suite in self.configuration["suites"]:
            name = suite["name"]
            inventory_gate = self.gates.get(f"enumerate_{name}", {})
            execution_gate = self.gates.get(f"execute_{name}", {})
            inventory_path = self.evidence / "inventory" / f"{name}.json"
            if execution_gate.get("status") in {"passed", "failed"} and inventory_gate.get("status") != "passed":
                missing.append(f"inventory/{name}.json")
            if inventory_gate.get("status") == "passed" and not inventory_path.is_file():
                missing.append(f"inventory/{name}.json")
            if self.suite_records.get(name, {}).get("executionStarted"):
                result_path = self.evidence / "results" / f"{name}-structured-results.json"
                if not result_path.is_file():
                    missing.append(f"results/{name}-structured-results.json")
                if suite["platform"] == "macos":
                    xctest_log = self.evidence / "logs" / f"{name}-xctest.log"
                    if not xctest_log.is_file():
                        missing.append(f"logs/{name}-xctest.log")
        forbidden = []
        for path in self.evidence.rglob("*"):
            if path.is_file() and path.suffix.lower() in {".sqlite", ".db", ".profraw", ".o", ".swiftmodule"}:
                forbidden.append(path.relative_to(self.evidence).as_posix())
        report = {
            "checkedAt": utc_now(),
            "passed": not missing and not forbidden,
            "missingRequiredEvidence": missing,
            "forbiddenArtifactFiles": forbidden,
            "excluded": ["DerivedData", "compiled products", "source copies", "candidate SQLite database"],
        }
        atomic_json(self.evidence / "evidence-completeness.json", report)
        with log.open("a", encoding="utf-8") as output:
            output.write(json.dumps(report, indent=2) + "\n")
        if missing or forbidden:
            raise GateFailure(f"Required evidence is missing or contains excluded artifacts: {report}", 2)

    def _plan(self) -> list[tuple[str, object]]:
        plan: list[tuple[str, object]] = [
            ("preflight", self._preflight),
            ("crawler_provision", self._provision_crawler),
            ("toolchain_capture", self._capture_toolchain),
            ("package_provision", self._package_provision),
            ("network_isolation_probe", self._network_probe),
            ("catalog_verify", self._catalog_verify),
            ("candidate_database_binding", self._verify_candidate_binding),
            ("pokedex_build", self._app_build),
        ]
        for suite in self.configuration["suites"]:
            plan.append((f"enumerate_{suite['name']}", lambda log, suite=suite: self._enumerate_suite(suite, log)))
            if suite["platform"] == "macos":
                plan.append((f"build_for_testing_{suite['name']}", lambda log, suite=suite: self._build_for_testing(suite, log)))
            plan.append((f"execute_{suite['name']}", lambda log, suite=suite: self._execute_suite(suite, log)))
        return plan

    def run(self) -> int:
        self._initialize()
        try:
            for name, action in self._plan():
                if not self._gate(name, action):
                    break
        except Exception as error:
            if self.first_failure is None:
                self.first_failure = {
                    "gate": "runner",
                    "exitCode": 2,
                    "failureKind": "runner_error",
                    "message": f"{type(error).__name__}: {error}",
                }
        # Integrity and evidence finalization run even after a gate failure.
        for name, action in (
            ("source_database_integrity", self._source_database_integrity),
            ("evidence_completeness", self._evidence_completeness),
        ):
            self._gate(name, action)
        self._release_failure_reserve()
        self.manifest["finishedAt"] = utc_now()
        self.manifest["runState"] = "failed" if self.first_failure else "passed"
        self.manifest["firstFailure"] = self.first_failure
        self._write_manifest()
        print(f"Verification {'failed' if self.first_failure else 'passed'}; evidence: {self.evidence}", flush=True)
        if self.first_failure:
            return int(self.first_failure["exitCode"])
        return 0


def main() -> int:
    runner = None
    try:
        runner = VerificationRunner()
        return runner.run()
    except Exception as error:
        disk_full = isinstance(error, OSError) and error.errno == errno.ENOSPC
        if disk_full and runner is not None:
            try:
                runner._release_failure_reserve()
            except OSError:
                pass
        failure_kind = "disk_exhaustion" if disk_full else "runner_error"
        print(
            f"release verification could not start ({failure_kind}): {type(error).__name__}: {error}",
            file=sys.stderr,
        )
        if disk_full:
            return errno.ENOSPC
        return 2


if __name__ == "__main__":
    sys.exit(main())
