import Foundation

public extension Request {
    /// A structure for configuring requests
    struct Config {
        private let request: Requestable
        private let server: ServerConfig
        /// Pre-encoded body data for JSON requests using `Encodable`. `nil` when not applicable.
        let encodedBody: Data?
        /// Pre-encoded multipart form data and its content type. `nil` when not applicable.
        let multipartData: (data: Data, contentType: String)?

        /// Init the request config with a requestable object and a server config
        /// - parameters:
        ///     - request: The given request to use for configuration
        ///     - server: The given server configuration to use
        ///     - encodedBody: Pre-encoded body data from an `Encodable` body. Defaults to `nil`.
        ///     - multipartData: Pre-encoded multipart body data and content type. Defaults to `nil`.
        init(request: Requestable, server: ServerConfig, encodedBody: Data? = nil, multipartData: (data: Data, contentType: String)? = nil) {
            self.request = request
            self.server = server
            self.encodedBody = encodedBody
            self.multipartData = multipartData
        }
    }
}

// MARK: -
public extension Request.Config {
    /// The URL for the request based on the server config and the request endpoint
    var url: URL { server.baseURL.appendingPathComponent(request.endpoint.path) }
    /// The default HTTP header for the given server config and request
    var header: HTTP.Header { server.header(forRequest: request) }
    /// The timeout interval for the given request
    var timeoutInterval: TimeInterval { request.timeoutInterval }
    /// The parameters for the request
    var parameters: HTTP.Parameters { request.parameters }
    /// The encoding for the request
    var encoding: Request.Encoding { request.encoding }
    /// The HTTP method for the request
    var httpMethod: HTTP.Method { request.httpMethod }
}
