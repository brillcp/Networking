import XCTest
import Combine
@testable import Networking

final class NetworkingTests: XCTestCase {
    private let serverConfig = ServerConfig(baseURL: try! "https://www.googleapis.com/books/v1".asURL())
    private lazy var networkService = Network.Service(server: serverConfig)

    func testMockUser() async throws {
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: MockVolumeModel = try await networkService.request(book)
        XCTAssertTrue(response.id == "qzcQCwAAQBAJ")
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
