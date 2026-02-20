import Foundation

/// A type that can adapt outgoing requests and decide whether to retry failed ones.
///
/// Implement `adapt` to modify requests before they are sent (e.g. add headers, sign requests).
/// Implement `retry` to recover from errors (e.g. refresh tokens on 401, retry on transient failures).
public protocol NetworkInterceptor: Sendable {
    /// Modify a `URLRequest` before it is sent over the network.
    /// - Parameter request: The request about to be sent.
    /// - Returns: The adapted request.
    func adapt(_ request: URLRequest) async throws -> URLRequest

    /// Decide whether a failed request should be retried.
    /// - Parameters:
    ///   - request: The request that failed.
    ///   - error: The error that caused the failure.
    ///   - attemptCount: The number of retries already attempted (starts at 0 for the first retry opportunity).
    /// - Returns: `true` to retry the request, `false` to let the error propagate.
    func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool
}

// MARK: - Default implementations
public extension NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest { request }
    func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool { false }
}
