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
    var parameters: HTTP.Parameters? { get }
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
    /// - parameters:
    ///     - server: The given server config to use
    ///     - logResponse: A boolean value that determines if the request data should be printed to the console
    /// - throws: An error if the request can't be build
    /// - returns: A new `URLRequest` with all the configurations
    func config(withServer server: ServerConfig, logResponse: Bool) throws -> URLRequest {
        let builder = RequestBuilder(config: .init(request: self, server: server))
        let request = try builder.build()
        if logResponse { request.log() }
        return request
    }
}

// MARK: -
public extension Requestable {
    var contentType: HTTP.ContentType { HTTP.Header.Field.json }
    var authorization: Request.Authorization { .none }
    var timeoutInterval: TimeInterval { 30.0 }
    var encoding: Request.Encoding { .query }
    var parameters: HTTP.Parameters? { nil }
    var method: HTTP.Method { .get }
}
