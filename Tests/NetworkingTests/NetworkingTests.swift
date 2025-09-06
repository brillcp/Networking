import Testing
import Foundation
@testable import Networking

protocol DownloaderProtocol {
    func download() async throws -> (URL, AsyncStream<Float>)
}

struct MockDownloader: DownloaderProtocol {
    func download() async throws -> (URL, AsyncStream<Float>) {
        let (stream, continuation) = AsyncStream<Float>.makeStream()
        continuation.yield(0.0)
        continuation.yield(0.5)
        continuation.yield(1.0)
        continuation.finish()
        // Use a dummy URL with .tmp extension
        let fileURL = URL(fileURLWithPath: "/tmp/mockfile.tmp")
        return (fileURL, stream)
    }
}

struct NetworkingTests {
    private let serverConfig = ServerConfig(baseURL: try! "https://www.googleapis.com/books/v1".asURL())
    private lazy var networkService = Network.Service(server: serverConfig)

    @Test
    mutating func mockUser() async throws {
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: MockVolumeModel = try await networkService.request(book)
        #expect(response.id == "qzcQCwAAQBAJ")
    }

    @Test
    mutating func downloadImageFile() async throws {
        let downloader = MockDownloader()
        let (fileURL, _) = try await downloader.download()
        #expect(fileURL.lastPathComponent.split(separator: ".").last == "tmp")
    }
}
