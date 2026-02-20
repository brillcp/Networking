import Foundation

/// A name space for request encoding and autorization
public enum Request {
    /// Encoding types for parameters for requests
    public enum Encoding {
        /// Encode parameters in the URL of a request. E.g `.../api/v1/endpoint?foo=bar`
        case query
        /// Encode parameters in the http body as json
        case json
        /// Encode parameters as a string in the http body. E.g `{foo=bar}`
        case body
        /// Encode using multipart/form-data for file uploads and mixed content
        case multipart
    }

    /// The different authorization types for a given request
    public enum Authorization {
        case bearer
        case basic
        case none
    }
}
