import Foundation

public extension HTTP {
    /// A response wrapper that includes the decoded body alongside HTTP metadata.
    struct Response<Body: Sendable>: Sendable {
        /// The decoded response body
        public let body: Body
        /// The HTTP status code of the response
        public let statusCode: StatusCode
        /// The response headers as a string dictionary
        public let headers: [String: String]

        public init(body: Body, statusCode: HTTP.StatusCode, headers: [String: String]) {
            self.body = body
            self.statusCode = statusCode
            self.headers = headers
        }
    }
}
