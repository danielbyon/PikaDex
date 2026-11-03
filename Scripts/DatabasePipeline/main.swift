import DatabasePipelineSupport
import Foundation

do {
    let options = try DatabasePipelineOptions.parse(
        Array(CommandLine.arguments.dropFirst()),
        currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    )
    try PipelineCoordinator().run(options)
} catch let error as PipelineError {
    FileHandle.standardError.write(Data("error: \(error.description)\n".utf8))
    exit(error.exitCode)
} catch {
    FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
    exit(3)
}
