import Foundation

public extension HTTP.Header {
    /// Header field values for HTTP requests
    enum Field {
        public static let urlEncoded = "application/x-www-form-urlencoded"
        public static let octetStream = "application/octet-stream"
        public static let contentLength = "Content-Length"
        public static let contentType = "Content-Type"
        public static let json = "application/json"
        public static let userAgent = "User-Agent"
        public static let auth = "Authorization"
        public static let bearer = "Bearer %@"
        public static let basic = "Basic %@"
        public static let accept = "Accept"
        public static let host = "Host"
    }
}
