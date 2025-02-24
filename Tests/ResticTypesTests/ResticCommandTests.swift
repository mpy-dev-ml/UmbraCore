@testable import ResticTypes
import XCTest

/// Test implementation of ResticCommand
private struct TestResticCommand: ResticCommand {
    let command: String
    let arguments: [String]
    let environment: [String: String]
    let requiredEnvironmentVariables: Set<String>

    func validate() throws {
        guard !command.isEmpty else {
            throw ResticError.invalidConfiguration("Command cannot be empty")
        }
    }
}

final class ResticCommandTests: XCTestCase {
    func testValidCommand() throws {
        let command = TestResticCommand(
            command: "backup",
            arguments: ["--tag", "test"],
            environment: ["RESTIC_PASSWORD": "test"],
            requiredEnvironmentVariables: ["RESTIC_PASSWORD"]
        )

        XCTAssertNoThrow(try command.validate())
    }

    func testInvalidCommand() {
        let command = TestResticCommand(
            command: "",
            arguments: [],
            environment: [:],
            requiredEnvironmentVariables: []
        )

        XCTAssertThrowsError(try command.validate()) { error in
            guard let resticError = error as? ResticError else {
                XCTFail("Expected ResticError")
                return
            }

            if case .invalidConfiguration(let message) = resticError {
                XCTAssertEqual(message, "Command cannot be empty")
            } else {
                XCTFail("Expected invalidConfiguration error")
            }
        }
    }

    func testResticErrorDescription() {
        let errors: [ResticError] = [
            .executionFailed("Command failed"),
            .outputParsingFailed("Invalid output"),
            .invalidConfiguration("Bad config"),
            .repositoryError("Repo error"),
            .authenticationError("Auth failed")
        ]

        let expectedDescriptions = [
            "Command execution failed: Command failed",
            "Output parsing failed: Invalid output",
            "Invalid configuration: Bad config",
            "Repository error: Repo error",
            "Authentication error: Auth failed"
        ]

        for (error, expectedDescription) in zip(errors, expectedDescriptions) {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
}
