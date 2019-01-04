import Foundation

public protocol RemoteRuleResolverProtocol {
    func remoteRule(forExecutable executable: String,
                    configuration: [String: Any]?) throws -> RemoteRule
}

public final class RemoteRuleResolver: RemoteRuleResolverProtocol {
    public init() {}

    public func remoteRule(forExecutable executable: String,
                           configuration: [String: Any]?) throws -> RemoteRule {
        let task = Process()
        task.launchPath = executable
        task.arguments = ["plugin_description"]

        let pipe = Pipe()
        task.standardOutput = pipe

        task.launch()

        let file = pipe.fileHandleForReading
        defer { file.closeFile() }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let description = try decoder.decode(PluginDescription.self, from: file.readDataToEndOfFile())
        return RemoteRule(description: description,
                          configuration: configuration?[description.ruleDescription.identifier])
    }
}
