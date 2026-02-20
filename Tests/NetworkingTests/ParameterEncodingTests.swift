import Testing
import Foundation
@testable import Networking

struct ParameterEncodingTests {
    private let server = ServerConfig(baseURL: try! "https://api.example.com".asURL())

    @Test
    func bodyEncodingPercentEncodesSpecialCharacters() throws {
        let request = MockBodyRequest(parameters: [
            "query": "hello world",
            "filter": "name=foo&bar"
        ])
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        let body = try #require(urlRequest.httpBody)
        let bodyString = try #require(String(data: body, encoding: .utf8))

        // Spaces should be percent-encoded
        #expect(bodyString.contains("hello%20world"))
        // '=' and '&' inside values should be percent-encoded, not treated as delimiters
        #expect(bodyString.contains("name%3Dfoo%26bar"))
        // Only one '&' as a separator between the two parameters
        #expect(bodyString.components(separatedBy: "&").count == 2)
    }

    @Test
    func bodyEncodingSetsContentTypeHeader() throws {
        let request = MockBodyRequest(parameters: ["key": "value"])
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
    }
}

// MARK: - Mocks

private enum MockBodyEndpoint: EndpointType {
    case test
    var path: String { "test" }
}

private struct MockBodyRequest: Requestable {
    var encoding: Request.Encoding { .body }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockBodyEndpoint.test }
    let parameters: HTTP.Parameters

    init(parameters: HTTP.Parameters) {
        self.parameters = parameters
    }
}
