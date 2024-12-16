import XCTest
import Combine
@testable import Networking

final class NetworkingTests: XCTestCase {
    private let serverConfig = ServerConfig(baseURL: try! "https://reqres.in/api".asURL())
    private lazy var networkService = Network.Service(server: serverConfig)

    func testMockUser() async throws {
        let user = MockGetRequest.user(1)
        let response: MockUserResponse = try await networkService.request(user)
        XCTAssertTrue(response.data.id == 1)
    }

    func testMockUsers() async throws {
        let users = MockGetRequest.users
        let response: MockUsersRepsonse = try await networkService.request(users)
        XCTAssertTrue(!response.data.isEmpty)
    }

    func testMockPostUser() async throws {
        let model = MockPostUserModel(name: "Viktor", job: "iOS Engineer")
        let users = MockPostRequest.user(model)
        let responseCode = try await networkService.response(users)
        XCTAssertTrue(responseCode == .created)
    }

    func testDownloadImageFile() async throws {
        let url = try "https://media.viktorgidlof.com/2022/12/djunglehorse.jpg".asURL()
        let downloader = networkService.downloader(url: url)
        let (fileURL, progress) = try await downloader.download()

        Task {
            for await progressValue in progress {
                print("Download progress: \(progressValue)")
            }
        }
        XCTAssertTrue(fileURL.lastPathComponent.split(separator: ".").last == "tmp")
    }
}
