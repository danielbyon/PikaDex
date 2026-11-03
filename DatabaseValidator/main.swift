import DatabasePipelineSupport
import Foundation

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 6,
          arguments[0] == "--database",
          arguments[2] == "--report",
          arguments[4] == "--summary" else {
        throw PipelineError.usage(
            "Usage: DatabaseValidator --database <path> --report <path> --summary <path>"
        )
    }
    let database = URL(fileURLWithPath: arguments[1])
    let reportURL = URL(fileURLWithPath: arguments[3])
    let summaryURL = URL(fileURLWithPath: arguments[5])
    let (snapshot, issues) = try CanonicalSnapshotBuilder.build(databaseURL: database)
    let report = try DatabaseValidationReport(databaseRole: "candidate", snapshot: snapshot, issues: issues)
    try PipelineIO.writeJSON(report, to: reportURL)
    try PipelineIO.writeValidationSummary(report, to: summaryURL)
    guard report.passed else {
        throw PipelineError.validation("Database validation failed with \(report.issues.count) issue(s)")
    }
    print("Database validation passed")
} catch let error as PipelineError {
    FileHandle.standardError.write(Data("error: \(error.description)\n".utf8))
    exit(error.exitCode)
} catch {
    FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
    exit(4)
}
