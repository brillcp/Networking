import Testing
import Foundation
@testable import Networking

struct ResponseTests {
    private let serverConfig = ServerConfig(baseURL: try! "https://www.googleapis.com/books/v1".asURL())
    private lazy var networkService = Network.Service(server: serverConfig)

    @Test
    mutating func sendDecodesBodyWithMetadata() async throws {
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: HTTP.Response<MockVolumeModel> = try await networkService.send(book)

        #expect(response.body.id == "qzcQCwAAQBAJ")
        #expect(response.statusCode == .ok)
        #expect(!response.headers.isEmpty)
    }

    @Test
    mutating func sendReturnsRawDataWithMetadata() async throws {
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: HTTP.Response<Data> = try await networkService.send(book)

        #expect(!response.body.isEmpty)
        #expect(response.statusCode == .ok)
        #expect(!response.headers.isEmpty)
    }
}
