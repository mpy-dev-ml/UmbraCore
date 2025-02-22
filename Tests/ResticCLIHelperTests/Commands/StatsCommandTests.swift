import Foundation
@testable import ResticCLIHelper
import XCTest

final class StatsCommandTests: XCTestCase {
    func testStatsCommandBuild() throws {
        let options = CommonOptions(
            repository: "/path/to/repo",
            password: "test"
        )

        let command = StatsCommand(options: options)
            .mode(.restoreSize)
            .host("test-host")
            .tag("test-tag")
            .path("/test/path")
            .snapshot("test-snapshot")

        XCTAssertEqual(command.commandName, "stats")
        XCTAssertEqual(command.commandArguments, [
            "test-snapshot",
            "--mode", "restore-size",
            "--host", "test-host",
            "--tag", "test-tag",
            "--path", "/test/path"
        ])

        XCTAssertEqual(command.environment["RESTIC_REPOSITORY"], "/path/to/repo")
        XCTAssertEqual(command.environment["RESTIC_PASSWORD"], "test")
    }

    func testStatsCommandExecution() async throws {
        let helper = ResticCLIHelper()
        let repo = try await TestRepository.create()

        let options = CommonOptions(
            repository: repo.path,
            password: repo.password,
            jsonOutput: true
        )

        let command = StatsCommand(options: options)
            .mode(.restoreSize)

        let output = try await helper.execute(command)
        XCTAssertFalse(output.isEmpty)
    }
}
