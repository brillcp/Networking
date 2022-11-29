//
//  ServerConfig.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// An object for creating a server configuration for the backend API
open class ServerConfig {

    // MARK: Private properties
    private let tokenProvider: TokenProvider?

    // MARK: - Public properties
    /// The base URL for the server
    public let baseURL: URL

    /// Init the server configuration
    /// - parameter baseURL: The given base URL used for this server config
    public init(baseURL: String, tokenProvider: TokenProvider? = nil) {
        self.baseURL = baseURL.asURL()
        self.tokenProvider = tokenProvider
    }

    /// Create a HTTP header for the requests.
    /// Subclasses can call `super` if they need to implement the standard authentication.
    /// Don't call `super` if you want to have a fully custom HTTP header implementation.
    /// - parameter request: The given request to set up the header with
    /// - returns: A new `HTTP.Header` dictionary
    open func header(forRequest request: Requestable) -> HTTP.Header {
        var header = HTTP.Header()

        if let contentType = request.contentType {
            header[HTTP.Header.Field.contentType] = contentType
        }

        guard let tokenProvider = tokenProvider else { return header }

        switch tokenProvider.token {
        case .success(let token):
            switch request.authorization {
            case .bearer: header[HTTP.Header.Field.auth] = String(format: HTTP.Header.Field.bearer, token)
            case .basic: header[HTTP.Header.Field.auth] = String(format: HTTP.Header.Field.basic, token)
            case .none: break
            }
        case .failure:
            break
        }
        return header
    }
}
