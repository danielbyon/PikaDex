import Foundation

/// The checked-in contract for reproducible database generation.
///
/// The manifest records every reviewed export that the loader may read.
/// Pipeline verification rejects files that are absent, changed, malformed, or
/// consumed without a manifest entry; it never repairs the reviewed input set
/// by downloading data or inferring a manual spreadsheet transformation.
public struct PipelineManifest: Codable, Equatable, Sendable {
    public static let supportedSchemaVersion = 4

    public let schemaVersion: Int
    public let canonicalSnapshotSchemaVersion: Int
    public let sourceInputs: [SourceInput]
    public let modelInputs: [Artifact]
    public let acquisitionSteps: [AcquisitionStep]
    public let toolchain: Toolchain

    public init(
        schemaVersion: Int,
        canonicalSnapshotSchemaVersion: Int,
        sourceInputs: [SourceInput],
        modelInputs: [Artifact],
        acquisitionSteps: [AcquisitionStep],
        toolchain: Toolchain
    ) {
        self.schemaVersion = schemaVersion
        self.canonicalSnapshotSchemaVersion = canonicalSnapshotSchemaVersion
        self.sourceInputs = sourceInputs
        self.modelInputs = modelInputs
        self.acquisitionSteps = acquisitionSteps
        self.toolchain = toolchain
    }

    public struct SourceInput: Codable, Equatable, Sendable {
        public enum Format: String, Codable, Sendable {
            case json
            case tsv
            case text
        }

        public let path: String
        public let sha256: String
        public let format: Format
        public let provenance: String
        public let encoding: String
        public let delimiter: String?
        public let requiredHeaders: [String]
        public let rowIdentity: RowIdentityPolicy
        public let orderingSemantics: String
        public let upstreamSources: [String]
        public let manualDocument: String?
        public let manualWorksheet: String?
        public let responsibleManualStep: String
        public let transformationBlocker: String?

        public init(
            path: String,
            sha256: String,
            format: Format,
            provenance: String,
            encoding: String = "utf-8",
            delimiter: String? = nil,
            requiredHeaders: [String] = [],
            rowIdentity: RowIdentityPolicy = .init(kind: .unorderedMultiset),
            orderingSemantics: String = "Canonical document-key order",
            upstreamSources: [String] = [],
            manualDocument: String? = nil,
            manualWorksheet: String? = nil,
            responsibleManualStep: String = "Review and approve the loader input",
            transformationBlocker: String? = nil
        ) {
            self.path = path
            self.sha256 = sha256
            self.format = format
            self.provenance = provenance
            self.encoding = encoding
            self.delimiter = delimiter
            self.requiredHeaders = requiredHeaders
            self.rowIdentity = rowIdentity
            self.orderingSemantics = orderingSemantics
            self.upstreamSources = upstreamSources
            self.manualDocument = manualDocument
            self.manualWorksheet = manualWorksheet
            self.responsibleManualStep = responsibleManualStep
            self.transformationBlocker = transformationBlocker
        }

        /// Declares the identity contract the existing loader actually applies.
        public struct RowIdentityPolicy: Codable, Equatable, Sendable {
            public enum Kind: String, Codable, Sendable {
                case uniqueKey
                case compositeUniqueKey
                case orderedMultiset
                case unorderedMultiset
                case positionalTable
            }

            public let kind: Kind
            public let columns: [String]

            public init(kind: Kind, columns: [String] = []) {
                self.kind = kind
                self.columns = columns
            }
        }
    }

    public struct Artifact: Codable, Equatable, Sendable {
        public let path: String
        public let sha256: String

        public init(path: String, sha256: String) {
            self.path = path
            self.sha256 = sha256
        }
    }

    public struct AcquisitionStep: Codable, Equatable, Sendable {
        public let identifier: String
        public let script: String
        public let outputs: [String]
        public let allowedHosts: [String]
        public let verified: Bool
        public let blocker: String?

        public init(
            identifier: String,
            script: String,
            outputs: [String],
            allowedHosts: [String],
            verified: Bool,
            blocker: String?
        ) {
            self.identifier = identifier
            self.script = script
            self.outputs = outputs
            self.allowedHosts = allowedHosts
            self.verified = verified
            self.blocker = blocker
        }
    }

    public struct Toolchain: Codable, Equatable, Sendable {
        public let xcode: String
        public let swiftLanguageMode: String
        public let python: String
        public let acquisitionRequirements: String

        public init(
            xcode: String,
            swiftLanguageMode: String,
            python: String,
            acquisitionRequirements: String
        ) {
            self.xcode = xcode
            self.swiftLanguageMode = swiftLanguageMode
            self.python = python
            self.acquisitionRequirements = acquisitionRequirements
        }
    }
}

public enum PipelineManifestLoader {
    /// Loads and validates a manifest without consulting the network.
    public static func load(from url: URL) throws -> PipelineManifest {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw PipelineError.missingPrerequisite("Pipeline manifest is missing or unreadable: \(url.path)")
        }

        let manifest: PipelineManifest
        do {
            manifest = try JSONDecoder().decode(PipelineManifest.self, from: data)
        } catch {
            throw PipelineError.invalidManifest("Could not decode \(url.lastPathComponent): \(error.localizedDescription)")
        }

        guard manifest.schemaVersion == PipelineManifest.supportedSchemaVersion else {
            throw PipelineError.invalidManifest(
                "Unsupported manifest schema \(manifest.schemaVersion); expected \(PipelineManifest.supportedSchemaVersion)"
            )
        }
        guard manifest.canonicalSnapshotSchemaVersion == CanonicalDatabaseSnapshot.schemaVersion else {
            throw PipelineError.invalidManifest(
                "Manifest snapshot schema \(manifest.canonicalSnapshotSchemaVersion) does not match tooling schema \(CanonicalDatabaseSnapshot.schemaVersion)"
            )
        }

        let paths = manifest.sourceInputs.map(\.path)
        guard Set(paths).count == paths.count else {
            throw PipelineError.invalidManifest("Source input paths must be unique")
        }
        guard paths == paths.sorted() else {
            throw PipelineError.invalidManifest("Source input paths must be sorted")
        }
        guard manifest.sourceInputs.allSatisfy({ PipelinePath.isRepositoryRelative($0.path) }) else {
            throw PipelineError.invalidManifest("Source input paths must be normalized repository-relative paths")
        }
        let hex = CharacterSet(charactersIn: "0123456789abcdef")
        guard manifest.sourceInputs.allSatisfy({
            $0.sha256.count == 64
                && $0.sha256.unicodeScalars.allSatisfy(hex.contains)
                && !$0.provenance.isEmpty
                && $0.encoding == "utf-8"
                && !$0.orderingSemantics.isEmpty
                && !$0.responsibleManualStep.isEmpty
                && $0.upstreamSources.allSatisfy(PipelinePath.isRepositoryRelative)
        }) else {
            throw PipelineError.invalidManifest(
                "Reviewed inputs require lowercase SHA-256 values, UTF-8 encoding, explicit row identity, ordering, provenance, and a responsible manual step"
            )
        }
        guard manifest.sourceInputs.allSatisfy({ input in
            switch input.format {
            case .tsv:
                guard input.delimiter == "\t", !input.requiredHeaders.isEmpty else { return false }
                switch input.rowIdentity.kind {
                case .uniqueKey:
                    return input.rowIdentity.columns.count == 1
                        && input.rowIdentity.columns.allSatisfy(input.requiredHeaders.contains)
                case .compositeUniqueKey:
                    return input.rowIdentity.columns.count > 1
                        && input.rowIdentity.columns.allSatisfy(input.requiredHeaders.contains)
                case .orderedMultiset, .unorderedMultiset:
                    return input.rowIdentity.columns.isEmpty
                case .positionalTable:
                    return !input.rowIdentity.columns.isEmpty
                }
            case .json, .text:
                return input.delimiter == nil
                    && input.requiredHeaders.isEmpty
                    && [.orderedMultiset, .unorderedMultiset].contains(input.rowIdentity.kind)
            }
        }) else {
            throw PipelineError.invalidManifest(
                "Reviewed inputs require a format-compatible unique, multiset, or positional row-identity policy"
            )
        }

        let acquisitionIdentifiers = manifest.acquisitionSteps.map(\.identifier)
        guard Set(acquisitionIdentifiers).count == acquisitionIdentifiers.count else {
            throw PipelineError.invalidManifest("Acquisition identifiers must be unique")
        }
        guard manifest.acquisitionSteps.allSatisfy({ step in
            !step.identifier.isEmpty
                && !step.allowedHosts.isEmpty
                && step.allowedHosts == Array(Set(step.allowedHosts)).sorted()
                && step.script == URL(fileURLWithPath: step.script).lastPathComponent
                && step.script.hasSuffix(".py")
                && step.outputs.allSatisfy(PipelinePath.isRepositoryRelative)
        }) else {
            throw PipelineError.invalidManifest(
                "Acquisition entries require a Python filename, sorted unique hosts, and safe output paths"
            )
        }

        return manifest
    }
}
