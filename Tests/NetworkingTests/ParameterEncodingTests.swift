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

    @Test
    func queryEncodingHandlesSpecialCharactersInURL() throws {
        let request = MockQueryRequest(parameters: ["q": "hello world", "filter": "a&b"])
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        let url = try #require(urlRequest.url)
        let query = try #require(url.query)

        // URLComponents percent-encodes values in query items
        #expect(query.contains("q=hello%20world") || query.contains("q=hello+world"))
        #expect(query.contains("filter=a%26b"))
    }
}

// MARK: - Mocks

private enum MockBodyEndpoint: EndpointType {
    case test
    var path: String { "test" }
}

private struct MockBodyRequest: Requestable, @unchecked Sendable {
    var encoding: Request.Encoding { .body }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockBodyEndpoint.test }
    nonisolated(unsafe) let parameters: HTTP.Parameters

    init(parameters: HTTP.Parameters) {
        self.parameters = parameters
    }
}

private struct MockQueryRequest: Requestable, @unchecked Sendable {
    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }
    var endpoint: EndpointType { MockBodyEndpoint.test }
    nonisolated(unsafe) let parameters: HTTP.Parameters

    init(parameters: HTTP.Parameters) {
        self.parameters = parameters
    }
}
