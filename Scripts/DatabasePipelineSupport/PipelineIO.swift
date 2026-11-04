import CryptoKit
import Foundation

public struct ReviewedInputPreflightReport: Codable, Equatable, Sendable {
    public let manifestSchemaVersion: Int
    public let passed: Bool
    public let findings: [ValidationIssue]

    public init(findings: [ValidationIssue]) {
        manifestSchemaVersion = PipelineManifest.supportedSchemaVersion
        let sortedFindings = findings.sorted()
        passed = !sortedFindings.contains(where: { $0.severity == .error })
        self.findings = sortedFindings
    }
}

public enum PipelineIO {
    public static func sha256(of url: URL) throws -> String {
        let data: Data
        do {
            data = try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            throw PipelineError.missingPrerequisite("Could not read \(url.path): \(error.localizedDescription)")
        }
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public static func verify(
        artifacts: [PipelineManifest.Artifact],
        repositoryRoot: URL
    ) throws {
        for artifact in artifacts.sorted(by: { $0.path < $1.path }) {
            let url = try PipelinePath.resolve(artifact.path, under: repositoryRoot)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PipelineError.missingPrerequisite("Manifest-declared file is missing: \(artifact.path)")
            }
            let actual = try sha256(of: url)
            guard actual == artifact.sha256 else {
                throw PipelineError.inputDrift(
                    "Checksum mismatch for \(artifact.path): expected \(artifact.sha256), found \(actual)"
                )
            }
        }
    }

    public static func verify(
        inputs: [PipelineManifest.SourceInput],
        repositoryRoot: URL,
        crawlersRoot: URL
    ) throws {
        for input in inputs.sorted(by: { $0.path < $1.path }) {
            let url = try PipelinePath.resolveSourceInput(
                input.path,
                repositoryRoot: repositoryRoot,
                crawlersRoot: crawlersRoot
            )
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PipelineError.missingPrerequisite("Manifest-declared file is missing: \(input.path)")
            }
            let actual = try sha256(of: url)
            guard actual == input.sha256 else {
                throw PipelineError.inputDrift(
                    "Checksum mismatch for \(input.path): expected \(input.sha256), found \(actual)"
                )
            }
        }
    }

    /// Verifies the reviewed loader-input boundary before normalization.
    ///
    /// This check deliberately has no crawler or Numbers dependency. It proves
    /// that every pinned export is readable with its declared encoding and that
    /// delimited exports satisfy their loader-compatible identity or positional
    /// contracts. The checked-in files are never rewritten by preflight.
    public static func preflightReviewedInputs(
        _ inputs: [PipelineManifest.SourceInput],
        repositoryRoot: URL,
        crawlersRoot: URL
    ) throws -> [ValidationIssue] {
        try verify(inputs: inputs, repositoryRoot: repositoryRoot, crawlersRoot: crawlersRoot)
        var findings = [ValidationIssue]()
        for input in inputs.sorted(by: { $0.path < $1.path }) {
            let url = try PipelinePath.resolveSourceInput(
                input.path,
                repositoryRoot: repositoryRoot,
                crawlersRoot: crawlersRoot
            )
            let data = try Data(contentsOf: url)
            guard String(data: data, encoding: .utf8) != nil else {
                findings.append(.init(
                    code: "unreadable_encoding",
                    entity: "ReviewedInput",
                    key: input.path,
                    message: "Input is not valid UTF-8 as declared"
                ))
                continue
            }

            switch input.format {
            case .json:
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                } catch {
                    findings.append(.init(
                        code: "malformed_json",
                        entity: "ReviewedInput",
                        key: input.path,
                        message: "Input is not valid JSON"
                    ))
                }
            case .tsv:
                findings.append(contentsOf: preflightDelimitedInput(input, data: data))
            case .text:
                break
            }
            findings.append(.init(
                severity: .info,
                code: "row_identity_policy",
                entity: "ReviewedInput",
                key: input.path,
                message: "Declared policy: \(input.rowIdentity.kind.rawValue)"
            ))
        }
        return findings.sorted()
    }

    private static func preflightDelimitedInput(
        _ input: PipelineManifest.SourceInput,
        data: Data
    ) -> [ValidationIssue] {
        var findings = [ValidationIssue]()
        let contents = String(decoding: data, as: UTF8.self)
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        let lines = contents.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        guard let first = lines.first, lines.count > 1 else {
            return [.init(
                code: "missing_data_rows",
                entity: "ReviewedInput",
                key: input.path,
                message: "Delimited input has no data rows"
            )]
        }

        let header = first.components(separatedBy: "\t")
        if header.contains(where: \.isEmpty) {
            findings.append(.init(
                severity: .warning,
                code: "legacy_blank_header",
                entity: "ReviewedInput",
                key: input.path,
                message: "Pinned positional layout contains blank header columns accepted by the loader"
            ))
        }
        if Set(header).count != header.count {
            findings.append(.init(
                severity: .warning,
                code: "legacy_duplicate_header",
                entity: "ReviewedInput",
                key: input.path,
                message: "Pinned layout contains duplicate header values accepted with last-column-wins lookup"
            ))
        }
        let missingHeaders = input.requiredHeaders.filter { !header.contains($0) }.sorted()
        if !missingHeaders.isEmpty {
            findings.append(.init(
                code: "missing_required_field",
                entity: "ReviewedInput",
                key: input.path,
                message: "Missing loader-required fields: \(missingHeaders.joined(separator: ", "))"
            ))
        }

        if input.rowIdentity.kind == .positionalTable {
            let expected = input.rowIdentity.columns
            if header.count != expected.count {
                findings.append(.init(
                    code: "missing_positional_column",
                    entity: "ReviewedInput",
                    key: input.path,
                    message: "Expected \(expected.count) positional columns, found \(header.count)"
                ))
            } else {
                for (index, contract) in expected.enumerated() {
                    let actual = header[index]
                    let matches = contract == "<blank>" ? actual.isEmpty : actual == contract
                    if !matches {
                        findings.append(.init(
                            code: "positional_column_mismatch",
                            entity: "ReviewedInput",
                            key: input.path,
                            message: "Column \(index) expected \(contract), found \(actual.isEmpty ? "<blank>" : actual)"
                        ))
                    }
                }
            }
        }

        var identities = Set<String>()
        for (offset, line) in lines.dropFirst().enumerated() {
            let columns = line.components(separatedBy: "\t")
            if columns.count != header.count {
                findings.append(.init(
                    code: "malformed_row_width",
                    entity: "ReviewedInput",
                    key: input.path,
                    message: "Row \(offset + 1) has \(columns.count) columns; expected \(header.count)"
                ))
                continue
            }

            switch input.rowIdentity.kind {
            case .uniqueKey, .compositeUniqueKey:
                let row = zip(header, columns).reduce(into: [String: String]()) { $0[$1.0] = $1.1 }
                let keyParts = input.rowIdentity.columns.map { row[$0] ?? "" }
                if !keyParts.contains(where: { !$0.isEmpty }) {
                    findings.append(.init(
                        code: "empty_unique_identity",
                        entity: "ReviewedInput",
                        key: input.path,
                        message: "Row \(offset + 1) has an empty established identity"
                    ))
                    continue
                }
                let identity = keyParts.joined(separator: "\u{001F}")
                if !identities.insert(identity).inserted {
                    findings.append(.init(
                        code: "duplicate_unique_identity",
                        entity: "ReviewedInput",
                        key: input.path,
                        message: "Duplicate established identity: \(keyParts.joined(separator: " | "))"
                    ))
                }
            case .orderedMultiset, .unorderedMultiset, .positionalTable:
                break
            }
        }
        return findings.sorted()
    }

    public static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(value)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    public static func writePreflightSummary(
        _ report: ReviewedInputPreflightReport,
        to url: URL
    ) throws {
        let counts = Dictionary(grouping: report.findings, by: \.severity).mapValues(\.count)
        var lines = [
            "status: \(report.passed ? "passed" : "failed")",
            "manifest-schema: \(report.manifestSchemaVersion)",
            "errors: \(counts[.error, default: 0])",
            "warnings: \(counts[.warning, default: 0])",
            "info: \(counts[.info, default: 0])"
        ]
        lines.append(contentsOf: report.findings.sorted().map {
            "finding.\($0.severity.rawValue).\($0.code): \($0.key) - \($0.message)"
        })
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    /// Writes a deterministic operator summary without paths or runtime metadata.
    public static func writeValidationSummary(_ report: DatabaseValidationReport, to url: URL) throws {
        var lines = [
            "status: \(report.passed ? "passed" : "failed")",
            "snapshot-schema: \(report.snapshotSchemaVersion)",
            "semantic-digest: \(report.semanticDigest)",
            "issues: \(report.issues.count)"
        ]
        lines.append(contentsOf: report.rowCounts.keys.sorted().map {
            "rows.\($0): \(report.rowCounts[$0]!)"
        })
        lines.append(contentsOf: report.issues.sorted().map {
            "issue.\($0.severity.rawValue).\($0.code): \($0.entity) [\($0.key)] \($0.message)"
        })
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    /// Creates deterministic derived input copies while leaving pinned sources untouched.
    public static func normalize(
        inputs: [PipelineManifest.SourceInput],
        repositoryRoot: URL,
        crawlersRoot: URL,
        destinationRoot: URL
    ) throws {
        try FileManager.default.createDirectory(at: destinationRoot, withIntermediateDirectories: true)
        for input in inputs.sorted(by: { $0.path < $1.path }) {
            let source = try PipelinePath.resolveSourceInput(
                input.path,
                repositoryRoot: repositoryRoot,
                crawlersRoot: crawlersRoot
            )
            let destination = destinationRoot.appendingPathComponent(input.path)
            try FileManager.default.createDirectory(
                at: destination.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            switch input.format {
            case .json:
                let object = try JSONSerialization.jsonObject(with: Data(contentsOf: source))
                let data = try JSONSerialization.data(
                    withJSONObject: object,
                    options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
                )
                var normalized = data
                normalized.append(0x0A)
                try normalized.write(to: destination, options: .atomic)
            case .tsv, .text:
                let contents = try String(contentsOf: source, encoding: .utf8)
                let normalized = contents
                    .replacingOccurrences(of: "\r\n", with: "\n")
                    .replacingOccurrences(of: "\r", with: "\n")
                    .trimmingCharacters(in: .newlines) + "\n"
                try normalized.write(to: destination, atomically: true, encoding: .utf8)
            }
        }
    }
}

public protocol PipelineProcessRunning {
    @discardableResult
    func run(
        executable: URL,
        arguments: [String],
        workingDirectory: URL?,
        environment: [String: String]
    ) throws -> Int32
}

public struct PipelineProcessRunner: PipelineProcessRunning {
    public init() { }

    @discardableResult
    public func run(
        executable: URL,
        arguments: [String],
        workingDirectory: URL?,
        environment: [String: String] = [:]
    ) throws -> Int32 {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = workingDirectory
        process.environment = ProcessInfo.processInfo.environment.merging(environment) { _, explicit in explicit }
        // Phase tools are intentionally quiet; deterministic reports are the
        // operator interface and stderr retains actionable failures.
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.standardError
        do {
            try process.run()
        } catch {
            throw PipelineError.generation("Could not launch \(executable.lastPathComponent): \(error.localizedDescription)")
        }
        process.waitUntilExit()
        return process.terminationStatus
    }
}
