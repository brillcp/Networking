import Testing
import Foundation
@testable import Networking

struct NetworkErrorTests {

    @Test
    func badServerResponseCarriesStatusCodeAndData() throws {
        let errorBody = Data("{\"error\": \"not found\"}".utf8)
        let error = Network.Service.NetworkError.badServerResponse(.notFound, errorBody)

        guard case .badServerResponse(let statusCode, let data) = error else {
            Issue.record("Expected badServerResponse")
            return
        }

        #expect(statusCode == .notFound)
        #expect(data == errorBody)

        let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: String])
        #expect(json["error"] == "not found")
    }

    @Test
    func badServerResponseErrorDescriptionUsesStatusCode() {
        let error = Network.Service.NetworkError.badServerResponse(.unauthorized, Data())
        #expect(error.errorDescription == "Server returned status code: 401")
    }
}
