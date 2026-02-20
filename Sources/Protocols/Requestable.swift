import Foundation

/// A protocol for a request type. Used to build backend API requests.
public protocol Requestable: Sendable {
    /// The request authorization. Defaults to `none`.
    var authorization: Request.Authorization { get }
    /// The content type of the request. Defaults to `nil`.
    var contentType: HTTP.ContentType? { get }
    /// A time interval for request timeout. Defaults to 30 seconds.
    var timeoutInterval: TimeInterval { get }
    /// The request parameters. Defaults to an empty dictionary.
    var parameters: HTTP.Parameters { get }
    /// An optional `Encodable` body for JSON requests. When provided with `.json` encoding,
    /// this is encoded directly using `JSONEncoder` instead of serializing `parameters`.
    var body: (any Encodable & Sendable)? { get }
    /// The encoding used fot the request
    var encoding: Request.Encoding { get }
    /// The request HTTP method
    var httpMethod: HTTP.Method { get }
    /// The API endpoint
    var endpoint: EndpointType { get }
}

// MARK: -
public extension Requestable {
    /// Configure a new `URLRequest` from a requestable object with a server configuration
    /// - parameter server: The given server config to use
    /// - parameter logger: The logger to use for request logging
    /// - parameter encoder: The JSON encoder to use for encoding the body. Defaults to a new `JSONEncoder`.
    /// - throws: An error if the request can't be build
    /// - returns: A new `URLRequest` with all the configurations
    func configure(withServer server: ServerConfig, using logger: NetworkLoggerProtocol, encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        var encodedBody: Data?
        if let body {
            encodedBody = try encoder.encode(body)
        }
        let config = Request.Config(request: self, server: server, encodedBody: encodedBody)
        let urlRequest = try URLRequest(withConfig: config)
        logger.logRequest(urlRequest)
        return urlRequest
    }
}

// MARK: -
public extension Requestable {
    var authorization: Request.Authorization { .none }
    var timeoutInterval: TimeInterval { 30.0 }
    var contentType: HTTP.ContentType? { nil }
    var parameters: HTTP.Parameters { [:] }
    var body: (any Encodable & Sendable)? { nil }
}
