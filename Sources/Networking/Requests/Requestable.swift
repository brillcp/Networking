//
//  RequestType.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// A protocol for a request type. Used to build backend API requests.
public protocol Requestable {
    /// The request authorization. Defaults to `none`.
    var authorization: Request.Authorization { get }
    /// The content type of the request. Defaults to `nil`.
    var contentType: HTTP.ContentType? { get }
    /// A time interval for request timeout. Defaults to 30 seconds.
    var timeoutInterval: TimeInterval { get }
    /// The request parameters. Defaults to an empty dictionary.
    var parameters: HTTP.Parameters { get }
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
    /// - throws: An error if the request can't be build
    /// - returns: A new `URLRequest` with all the configurations
    func configure(withServer server: ServerConfig) throws -> URLRequest {
        let config = Request.Config(request: self, server: server)
        let urlRequest = try URLRequest(withConfig: config)
        urlRequest.log()
        return urlRequest
    }
}

// MARK: -
public extension Requestable {
    var authorization: Request.Authorization { .none }
    var timeoutInterval: TimeInterval { 30.0 }
    var contentType: HTTP.ContentType? { nil }
    var parameters: HTTP.Parameters { [:] }
}
