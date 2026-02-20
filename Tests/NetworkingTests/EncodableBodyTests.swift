import Testing
import Foundation
@testable import Networking

struct EncodableBodyTests {
    private let server = ServerConfig(baseURL: try! "https://api.example.com".asURL())

    @Test
    func requestWithEncodableBodyEncodesDirectlyAsJSON() throws {
        let request = MockPostRequest.createUser(name: "Viktor", age: 30)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let urlRequest = try request.configure(withServer: server, using: NetworkLogger(), encoder: encoder)

        let bodyData = try #require(urlRequest.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        #expect(json["name"] as? String == "Viktor")
        #expect(json["age"] as? Int == 30)
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test
    func requestWithoutBodyFallsBackToParametersForJSON() throws {
        let request = MockLegacyPostRequest()
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        let bodyData = try #require(urlRequest.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        #expect(json["key"] as? String == "value")
    }
}

// MARK: - Mocks

private struct UserBody: Encodable, Sendable {
    let name: String
    let age: Int
}

private enum MockPostEndpoint: EndpointType {
    case users
    var path: String { "users" }
}

private enum MockPostRequest: Requestable {
    case createUser(name: String, age: Int)

    var encoding: Request.Encoding { .json }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockPostEndpoint.users }

    var body: (any Encodable & Sendable)? {
        switch self {
        case .createUser(let name, let age):
            return UserBody(name: name, age: age)
        }
    }
}

private struct MockLegacyPostRequest: Requestable {
    var encoding: Request.Encoding { .json }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockPostEndpoint.users }
    var parameters: HTTP.Parameters { ["key": "value"] }
}
