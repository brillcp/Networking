import Foundation

/// A type that defines configuration details for communicating with a server.
///
/// Conforming types provide a `baseURL` for requests and a method to
/// generate request headers, potentially including authentication and
/// other metadata required by the server.
public protocol ServerConfigurable {
    /// The base URL used to construct requests to the server.
    var baseURL: URL { get }

    /// Produces the HTTP headers for a given request.
    ///
    /// - Parameter request: The request for which to construct headers.
    /// - Returns: A dictionary of HTTP header fields to include with the request.
    func header(forRequest request: Requestable) -> HTTP.Header
}

// MARK: -
public struct ServerConfig: ServerConfigurable {
    // MARK: Private properties
    private let additionalHeaders: HTTP.Header

    // MARK: - Public properties
    public let userAgent: String?
    /// A provider for authorization tokens used to authenticate requests; `nil` if no authentication is needed.
    public let tokenProvider: TokenProvidable?
    /// The base URL for the server
    public let baseURL: URL

    // MARK: - Initialization
    /// Initializes a new instance of `ServerConfig` with the specified configuration details.
    /// - Parameters:
    ///   - baseURL: A `String` representing the base URL for the server. This URL will be used as the primary endpoint for all requests.
    ///   - userAgent: An optional `String` representing the user agent to include in the request headers. If not provided, it defaults to a string combining `name` and `version`.
    ///   - additionalHeaders: An optional dictionary of additional headers to be merged into the default headers for each request. The default value is an empty dictionary.
    ///   - tokenProvider: An optional `TokenProvidable` object used to authenticate requests. This provider supplies authorization tokens when required by a request. Defaults to `nil`, meaning no token is provided.
    /// - Returns: A configured instance of `ServerConfig` with the specified parameters.
    public init(
        baseURL: URL,
        userAgent: String? = "\(name)/\(version)",
        additionalHeaders: HTTP.Header = [:],
        tokenProvider: TokenProvidable? = nil
    ) {
        self.baseURL = baseURL
        self.userAgent = userAgent
        self.additionalHeaders = additionalHeaders
        self.tokenProvider = tokenProvider
    }
}

// MARK: - Public functions
public extension ServerConfig {
    func header(forRequest request: Requestable) -> HTTP.Header {
        var headers = HTTP.Header()

        // Base headers
        if let host = baseURL.host { headers[HTTP.Header.Field.host] = host }
        if let userAgent = userAgent { headers[HTTP.Header.Field.userAgent] = userAgent }
        if let contentType = request.contentType { headers[HTTP.Header.Field.contentType] = contentType }

        // Add any additional configured headers
        headers.merge(additionalHeaders) { _, new in new }

        guard let tokenProvider else { return headers }

        switch tokenProvider.token {
        case .success(let token):
            guard let authHeader = authorizationHeader(for: request.authorization, token: token) else { break }
            headers[HTTP.Header.Field.auth] = authHeader
        case .failure: break
        }
        return headers
    }
}

// MARK: - Convenience Initializers
public extension ServerConfig {
    static func basic(baseURL: URL) -> ServerConfig {
        .init(baseURL: baseURL)
    }

    static func authenticated(baseURL: URL, tokenProvider: TokenProvidable) -> ServerConfig {
        .init(baseURL: baseURL, tokenProvider: tokenProvider)
    }
}

// MARK: - Private functions
private extension ServerConfig {
    func authorizationHeader(for type: Request.Authorization, token: String) -> String? {
        switch type {
        case .bearer: return String(format: HTTP.Header.Field.bearer, token)
        case .basic: return String(format: HTTP.Header.Field.basic, token)
        case .none: return nil
        }
    }
}
