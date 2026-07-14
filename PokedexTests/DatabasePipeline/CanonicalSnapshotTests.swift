import DatabasePipelineSupport
import PokedexCore
import XCTest

final class CanonicalSnapshotTests: XCTestCase {
    func testComparisonUsesVersionedSemanticContentAndExactRowCounts() throws {
        let record = CanonicalDatabaseSnapshot.Record(
            key: "StoredPokemon:key",
            attributes: [.init(name: "z_game", value: "string:national")],
            relationships: []
        )
        let baseline = CanonicalDatabaseSnapshot(
            modelFingerprint: "model",
            datasets: ["national"],
            entities: [.init(name: "StoredPokemon", records: [record])]
        )
        let equal = try SemanticComparisonReport(baseline: baseline, candidate: baseline)
        XCTAssertTrue(equal.matches)
        XCTAssertTrue(equal.rowCountChanges.isEmpty)
        XCTAssertEqual(equal.snapshotSchemaVersion, 2)
        XCTAssertEqual(equal.baselineValidationIssueCount, 0)

        let drift = CanonicalDatabaseSnapshot(
            modelFingerprint: "model",
            datasets: ["national"],
            entities: [.init(name: "StoredPokemon", records: [])]
        )
        let changed = try SemanticComparisonReport(baseline: baseline, candidate: drift)
        XCTAssertFalse(changed.matches)
        XCTAssertEqual(changed.rowCountChanges.first?.baseline, 1)
        XCTAssertEqual(changed.rowCountChanges.first?.candidate, 0)

        let invalidButEqual = SemanticComparisonReport(
            baselineDigest: "same",
            candidateDigest: "same",
            baselineRowCounts: ["StoredPokemon": 1],
            candidateRowCounts: ["StoredPokemon": 1],
            baselineEntityDigests: ["StoredPokemon": "entity-same"],
            candidateEntityDigests: ["StoredPokemon": "entity-same"],
            baselineValidationIssueCount: 2,
            candidateValidationIssueCount: 3
        )
        XCTAssertTrue(invalidButEqual.matches)
        XCTAssertEqual(invalidButEqual.candidateValidationIssueCount, 3)
        XCTAssertTrue(invalidButEqual.semanticEntityChanges.isEmpty)
    }

    func testValidationIssuesHaveStableOrdering() throws {
        let snapshot = CanonicalDatabaseSnapshot(modelFingerprint: "model", datasets: [], entities: [])
        let report = try DatabaseValidationReport(
            databaseRole: "candidate",
            snapshot: snapshot,
            issues: [
                .init(code: "z", entity: "B", key: "2", message: "last"),
                .init(code: "a", entity: "A", key: "1", message: "first")
            ]
        )
        XCTAssertEqual(report.issues.map(\.code), ["a", "z"])
        XCTAssertFalse(report.passed)

        let warningOnly = try DatabaseValidationReport(
            databaseRole: "baseline",
            snapshot: snapshot,
            issues: [.init(severity: .warning, code: "legacy", entity: "A", key: "1", message: "accepted")]
        )
        XCTAssertTrue(warningOnly.passed)
    }

    func testBaselineAwareValidationAllowsSharedWarningsAndRejectsNewOrEscalatedErrors() throws {
        let snapshot = CanonicalDatabaseSnapshot(modelFingerprint: "model", datasets: [], entities: [])
        let warning = ValidationIssue(
            severity: .warning,
            code: "legacy",
            entity: "StoredPokemon",
            key: "same",
            message: "Baseline anomaly"
        )
        let compatible = try SemanticComparisonReport(
            baseline: snapshot,
            candidate: snapshot,
            baselineIssues: [warning],
            candidateIssues: [warning]
        )
        XCTAssertTrue(compatible.validationCompatible)
        XCTAssertTrue(compatible.newErrors.isEmpty)

        let escalated = ValidationIssue(
            severity: .error,
            code: warning.code,
            entity: warning.entity,
            key: warning.key,
            message: warning.message
        )
        let incompatible = try SemanticComparisonReport(
            baseline: snapshot,
            candidate: snapshot,
            baselineIssues: [warning],
            candidateIssues: [escalated, .init(code: "new", entity: "A", key: "2", message: "New error")]
        )
        XCTAssertFalse(incompatible.validationCompatible)
        XCTAssertEqual(incompatible.severityIncreases.count, 1)
        XCTAssertEqual(incompatible.newErrors.map(\.code), ["new"])
    }

    func testSemanticDifferenceSummaryNamesChangedDomainFields() throws {
        let baselineRecord = CanonicalDatabaseSnapshot.Record(
            key: "pokemon",
            attributes: [.init(name: "z_name", value: "string:Old")],
            relationships: []
        )
        let candidateRecord = CanonicalDatabaseSnapshot.Record(
            key: "pokemon",
            attributes: [.init(name: "z_name", value: "string:New")],
            relationships: []
        )
        let baseline = CanonicalDatabaseSnapshot(
            modelFingerprint: "model",
            datasets: [],
            entities: [.init(name: "StoredPokemon", records: [baselineRecord])]
        )
        let candidate = CanonicalDatabaseSnapshot(
            modelFingerprint: "model",
            datasets: [],
            entities: [.init(name: "StoredPokemon", records: [candidateRecord])]
        )
        let report = try SemanticComparisonReport(
            baseline: baseline,
            candidate: candidate,
            baselineIssues: [],
            candidateIssues: []
        )
        XCTAssertEqual(report.semanticDifferences.first?.entity, "StoredPokemon")
        XCTAssertEqual(report.semanticDifferences.first?.changedAttributes.first?.name, "z_name")
    }

    func testHumanValidationSummaryIsDeterministicAndPathFree() throws {
        let snapshot = CanonicalDatabaseSnapshot(
            modelFingerprint: "model",
            datasets: ["national"],
            entities: [.init(name: "StoredPokemon", records: [])]
        )
        let report = try DatabaseValidationReport(databaseRole: "candidate", snapshot: snapshot, issues: [])
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PipelineSummaryTests-\(UUID().uuidString)")
        let first = directory.appendingPathComponent("first.txt")
        let second = directory.appendingPathComponent("second.txt")
        defer { try? FileManager.default.removeItem(at: directory) }

        try PipelineIO.writeValidationSummary(report, to: first)
        try PipelineIO.writeValidationSummary(report, to: second)

        let firstData = try Data(contentsOf: first)
        XCTAssertEqual(firstData, try Data(contentsOf: second))
        let text = String(decoding: firstData, as: UTF8.self)
        XCTAssertFalse(text.contains(directory.path))
        XCTAssertFalse(text.contains("timestamp"))
    }

    func testStableKeySchemaCoversEveryCatalogEntity() {
        XCTAssertEqual(
            Set(CanonicalSnapshotBuilder.stableKeyComponents.keys),
            [
                "StoredAbility", "StoredBagItemInfo", "StoredBerryItemInfo", "StoredEvolution",
                "StoredItem", "StoredLearnsetEntry", "StoredLocation", "StoredLocationMap",
                "StoredLocationPokemon", "StoredMachine", "StoredMove", "StoredPokedexNumbers",
                "StoredPokemon", "StoredPokemonForm", "StoredStats"
            ]
        )
    }

    func testSnapshotSchemaExcludesOnlyCoupledAbilityLookupCaches() {
        XCTAssertEqual(
            CanonicalSnapshotBuilder.excludedDerivedAttributes,
            [
                "StoredAbility": ["z_index"],
                "StoredPokemonForm": [
                    "i_hiddenAbilityIndex",
                    "i_primaryAbilityIndex",
                    "i_secondaryAbilityIndex"
                ]
            ]
        )
        XCTAssertFalse(
            CanonicalSnapshotBuilder.excludedDerivedAttributes["StoredPokemon", default: []]
                .contains("z_spriteName")
        )
    }

    func testDuplicateDetectionUsesExplicitStableKeys() {
        let record = CanonicalDatabaseSnapshot.Record(key: "same", attributes: [], relationships: [])
        let issues = CanonicalSnapshotBuilder.duplicateStableKeyIssues(
            entity: "StoredPokemon",
            records: [record, record]
        )
        XCTAssertEqual(issues.map(\.code), ["duplicate_stable_key"])
        XCTAssertEqual(issues.map(\.severity), [.warning])
        XCTAssertTrue(issues[0].message.contains("2 records"))
    }

    func testDatasetCoverageRequiresNationalAndEveryReleasedGame() {
        let requiredEntities = ["StoredItem", "StoredMove", "StoredPokemon", "StoredPokemonForm"]
        let records = Game.allDatasets.map { game in
            CanonicalDatabaseSnapshot.Record(
                key: game.rawValue,
                attributes: [.init(name: "z_game", value: "string:\(game.rawValue)")],
                relationships: []
            )
        }
        let complete = requiredEntities.map {
            CanonicalDatabaseSnapshot.Entity(name: $0, records: records)
        }
        XCTAssertTrue(CanonicalSnapshotBuilder.datasetCoverageIssues(entities: complete).isEmpty)

        let withoutNational: [CanonicalDatabaseSnapshot.Entity] = complete.map { entity in
            CanonicalDatabaseSnapshot.Entity(
                name: entity.name,
                records: entity.records.filter { $0.key != Game.national.rawValue }
            )
        }
        let issues = CanonicalSnapshotBuilder.datasetCoverageIssues(entities: withoutNational)
        XCTAssertEqual(issues.count, requiredEntities.count)
        XCTAssertEqual(Set(issues.map { $0.key }), [Game.national.rawValue])
    }
}
