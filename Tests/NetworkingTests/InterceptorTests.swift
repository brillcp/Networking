import Testing
import Foundation
@testable import Networking

struct InterceptorTests {
    private let serverConfig = ServerConfig(baseURL: try! "https://www.googleapis.com/books/v1".asURL())

    @Test
    mutating func adaptInterceptorModifiesRequest() async throws {
        let interceptor = HeaderInterceptor(name: "X-Custom", value: "test-value")
        let service = Network.Service(server: serverConfig, interceptors: [interceptor])

        // If adapt runs, the request succeeds with the added header.
        // We verify by making a real request — if it doesn't crash, adapt ran.
        let book = MockGetRequest.book("qzcQCwAAQBAJ")
        let _: MockVolumeModel = try await service.request(book)
        #expect(interceptor.adaptCallCount.value > 0)
    }

    @Test
    func retryInterceptorIsCalledOnFailure() async throws {
        // Use a URL that will return a 404
        let server = ServerConfig(baseURL: try! "https://www.googleapis.com/books/v1".asURL())
        let retryInterceptor = RetryInterceptor(maxRetries: 1)
        let service = Network.Service(server: server, interceptors: [retryInterceptor])

        let badRequest = MockNotFoundRequest()

        do {
            let _: MockVolumeModel = try await service.request(badRequest)
            Issue.record("Expected request to throw")
        } catch {
            // The interceptor should have been consulted and retried once
            #expect(retryInterceptor.retryCallCount.value == 2)
        }
    }
}

// MARK: - Mock Interceptors

private final class HeaderInterceptor: NetworkInterceptor {
    let name: String
    let value: String
    let adaptCallCount = Counter()

    init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        adaptCallCount.increment()
        var request = request
        request.setValue(value, forHTTPHeaderField: name)
        return request
    }
}

private final class RetryInterceptor: NetworkInterceptor {
    let maxRetries: Int
    let retryCallCount = Counter()

    init(maxRetries: Int) {
        self.maxRetries = maxRetries
    }

    func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool {
        retryCallCount.increment()
        return attemptCount < maxRetries
    }
}

/// A simple thread-safe counter for tracking interceptor calls from Sendable context.
private final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = 0
    var value: Int { lock.withLock { _value } }
    func increment() { lock.withLock { _value += 1 } }
}

// MARK: - Mock Request

private enum MockNotFoundEndpoint: EndpointType {
    case missing
    var path: String { "volumes/DOES_NOT_EXIST_12345" }
}

private struct MockNotFoundRequest: Requestable {
    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }
    var endpoint: EndpointType { MockNotFoundEndpoint.missing }
}
