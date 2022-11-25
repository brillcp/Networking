//
//  RequestType.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// A protocol for a request type. Used to build backend API requests.
public protocol Requestable {
    /// The request authorization
    var authorization: Request.Authorization { get }
    /// A time interval for request timeout
    var timeoutInterval: TimeInterval { get }
    /// The content type of the request
    var contentType: HTTP.ContentType { get }
    /// The request parameters
    var parameters: HTTP.Parameters { get }
    /// The API endpoint
    var endpoint: EndpointType { get }
    /// The request HTTP method
    var method: HTTP.Method { get }
    /// The encoding used fot the request
    var encoding: Request.Encoding { get }
}

// MARK: -
public extension Requestable {
    /// Configure a requestable object with a server configuration
    /// - parameter server: The given server config to use
    /// - throws: An error if the request can't be build
    /// - returns: A new `URLRequest` with all the configurations
    func configure(withServer server: ServerConfig) throws -> URLRequest {
        let config = Request.Config(request: self, server: server)
        var urlRequest = URLRequest(withConfig: config)
        urlRequest.log()

        guard !config.parameters.isEmpty else { return urlRequest }

        switch config.httpMethod {
        case .get, .delete: return try urlRequest.urlEncode(withParameters: parameters)
        case .post, .put:
            switch config.encoding {
            case .json: return try urlRequest.jsonEncode(withParameters: parameters)
            case .query: return urlRequest
            }
        }
    }
}

// MARK: -
public extension Requestable {
    var contentType: HTTP.ContentType { HTTP.Header.Field.json }
    var authorization: Request.Authorization { .none }
    var timeoutInterval: TimeInterval { 30.0 }
    var encoding: Request.Encoding { .query }
    var parameters: HTTP.Parameters { [:] }
    var method: HTTP.Method { .get }
}
