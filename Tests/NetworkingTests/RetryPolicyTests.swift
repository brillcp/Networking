import Testing
import Foundation
@testable import Networking

struct RetryPolicyTests {

    @Test
    func retriesOnRetryableStatusCode() async throws {
        let policy = RetryPolicy(maxRetryCount: 2, baseDelay: 0.01)
        let request = URLRequest(url: try "https://example.com".asURL())
        let error = Network.Service.NetworkError.badServerResponse(.serviceUnavailable, Data())

        let firstRetry = try await policy.retry(request, dueTo: error, attemptCount: 0)
        let secondRetry = try await policy.retry(request, dueTo: error, attemptCount: 1)
        let thirdRetry = try await policy.retry(request, dueTo: error, attemptCount: 2)

        #expect(firstRetry == true)
        #expect(secondRetry == true)
        #expect(thirdRetry == false)
    }

    @Test
    func doesNotRetryOnNonRetryableStatusCode() async throws {
        let policy = RetryPolicy(maxRetryCount: 2, baseDelay: 0.01)
        let request = URLRequest(url: try "https://example.com".asURL())
        let error = Network.Service.NetworkError.badServerResponse(.notFound, Data())

        let shouldRetry = try await policy.retry(request, dueTo: error, attemptCount: 0)
        #expect(shouldRetry == false)
    }
}
