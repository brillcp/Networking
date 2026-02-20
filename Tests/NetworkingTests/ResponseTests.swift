import Testing
import Foundation
@testable import Networking

struct ResponseTests {
    @Test
    func sendDecodesBodyWithMetadata() async throws {
        let service = Network.Service(server: ServerConfig(baseURL: try "https://www.googleapis.com/books/v1".asURL()))
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: HTTP.Response<MockVolumeModel> = try await service.send(book)

        #expect(response.body.id == "qzcQCwAAQBAJ")
        #expect(response.statusCode == .ok)
        #expect(!response.headers.isEmpty)
    }

    @Test
    func sendReturnsRawDataWithMetadata() async throws {
        let service = Network.Service(server: ServerConfig(baseURL: try "https://www.googleapis.com/books/v1".asURL()))
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let response: HTTP.Response<Data> = try await service.send(book)

        #expect(!response.body.isEmpty)
        #expect(response.statusCode == .ok)
        #expect(!response.headers.isEmpty)
    }
}
