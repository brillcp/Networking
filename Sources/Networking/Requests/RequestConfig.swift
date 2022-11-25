//
//  RequestConfig.swift
//  
//
//  Created by Viktor Gidlöf on 2022-11-25.
//

import Foundation

public extension RequestBuilder {

    struct Config {
        private let request: Requestable
        private let server: ServerConfig

        init(request: Requestable, server: ServerConfig) {
            self.request = request
            self.server = server
        }
    }
}

// MARK: -
public extension RequestBuilder.Config {
    /// The URL for the request based on the server config and the request endpoint
    var url: URL { server.baseURL.appendingPathComponent(request.endpoint.path) }
    /// The default HTTP header for the given server config and request
    var header: HTTP.Header { server.header(forRequest: request) }
    /// The HTTP content type for the request
    var contentType: HTTP.ContentType { request.contentType }
    /// The timeout interval for the given request
    var timeoutInterval: TimeInterval { request.timeoutInterval }
    /// The http parameters of the request
    var parameters: HTTP.Parameters? { request.parameters }
    /// The encoding to use on the request parameters
    var encoding: Request.Encoding { request.encoding }
    /// The HTTP method for the request
    var httpMethod: HTTP.Method { request.method }
}
