//
//  URLRequestBuilder.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

/// A structure for building requests for the backend API.
/// It takes a `Config` object that contains the request and the server config.
public struct RequestBuilder {

    // MARK: Private properties
    private let config: Config

    // MARK: - Init
    /// Init a request builder with a config object
    /// - parameter config: The given config object
    public init(config: Config) {
        self.config = config
    }
}

// MARK: -
public extension RequestBuilder {
    /// Build a new `URLRequest` from the request, server configuration and parameters
    /// - throws: An error if the url request can't be encoded
    /// - returns: A new encoded `URLRequest` with all the right headers and so on
    func build() throws -> URLRequest {
        var urlRequest = URLRequest(from: config)

        guard let parameters = config.parameters, !parameters.isEmpty else { return urlRequest }

        switch config.httpMethod {
        case .post: return try urlRequest.jsonEncode(withParameters: parameters)
        case .get: return try urlRequest.urlEncode(withParameters: parameters)
        }
    }
}
