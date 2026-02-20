import Foundation

/// A built-in interceptor that retries failed requests with exponential backoff.
///
/// Retries on configurable HTTP status codes (defaults to common transient errors)
/// and optionally on network connectivity errors.
///
/// ```swift
/// let service = Network.Service(
///     server: config,
///     interceptors: [RetryPolicy()]
/// )
/// ```
public struct RetryPolicy: NetworkInterceptor {
    /// The maximum number of retries before giving up.
    public let maxRetryCount: Int
    /// The HTTP status codes that should trigger a retry.
    public let retryableStatusCodes: Set<HTTP.StatusCode>
    /// Whether to retry on network connectivity errors.
    public let retryOnNetworkError: Bool
    /// The base delay in seconds before the first retry. Doubles with each subsequent retry.
    public let baseDelay: TimeInterval

    /// The default set of HTTP status codes considered retryable.
    public static let defaultRetryableStatusCodes: Set<HTTP.StatusCode> = [
        .requestTimeout,
        .tooManyRequests,
        .internalServerError,
        .badGateway,
        .serviceUnavailable,
        .gatewayTimeout
    ]

    /// Create a retry policy.
    /// - Parameters:
    ///   - maxRetryCount: Maximum number of retries. Defaults to `2`.
    ///   - retryableStatusCodes: Status codes to retry on. Defaults to 408, 429, 500, 502, 503, 504.
    ///   - retryOnNetworkError: Whether to retry on network errors. Defaults to `true`.
    ///   - baseDelay: Base delay in seconds for exponential backoff. Defaults to `1.0`.
    public init(
        maxRetryCount: Int = 2,
        retryableStatusCodes: Set<HTTP.StatusCode> = RetryPolicy.defaultRetryableStatusCodes,
        retryOnNetworkError: Bool = true,
        baseDelay: TimeInterval = 1.0
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryableStatusCodes = retryableStatusCodes
        self.retryOnNetworkError = retryOnNetworkError
        self.baseDelay = baseDelay
    }

    public func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool {
        guard attemptCount < maxRetryCount else { return false }

        let shouldRetry: Bool
        switch error {
        case .badServerResponse(let statusCode, _):
            shouldRetry = retryableStatusCodes.contains(statusCode)
        case .networkError:
            shouldRetry = retryOnNetworkError
        case .encodingError, .decodingError:
            shouldRetry = false
        }

        guard shouldRetry else { return false }

        let delay = baseDelay * pow(2.0, Double(attemptCount))
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        return true
    }
}
