import Testing
import Foundation
@testable import Networking

struct HTTPMethodTests {
    private let server = ServerConfig(baseURL: try! "https://api.example.com".asURL())

    @Test
    func patchMethodIsSetOnURLRequest() throws {
        let request = MockMethodRequest(method: .patch)
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        #expect(urlRequest.httpMethod == "PATCH")
    }

    @Test
    func headMethodIsSetOnURLRequest() throws {
        let request = MockMethodRequest(method: .head)
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        #expect(urlRequest.httpMethod == "HEAD")
    }
}

// MARK: - Mocks

private enum MockMethodEndpoint: EndpointType {
    case resource
    var path: String { "resource" }
}

private struct MockMethodRequest: Requestable {
    var encoding: Request.Encoding { .query }
    let httpMethod: HTTP.Method
    var endpoint: EndpointType { MockMethodEndpoint.resource }

    init(method: HTTP.Method) {
        self.httpMethod = method
    }
}
