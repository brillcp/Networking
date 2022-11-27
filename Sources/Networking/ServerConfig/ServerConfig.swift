//
//  ServerConfig.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// An object for creating a server configuration for the backend API
open class ServerConfig {
    /// The base URL for the server
    public let baseURL: URL

    /// Init the server configuration
    /// - parameter baseURL: The given base URL used for this server config
    public init(baseURL: String) {
        self.baseURL = baseURL.asURL()
    }

    /// Create a HTTP header for the requests. Defaults to `[Content-Type: application/json]`
    /// - parameter request: The given request to set up the header with
    /// - returns: A new `HTTP.Header` dictionary
    public func header(forRequest request: Requestable) -> HTTP.Header {
        guard let contentType = request.contentType else {
            return HTTP.Header()
        }
        return [HTTP.Header.Field.contentType: contentType]
    }
}
