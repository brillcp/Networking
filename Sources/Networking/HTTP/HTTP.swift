//
//  HTTP.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

/// A name space for all things HTTP
public enum HTTP {
    public typealias Parameters = [String: Any]
    public typealias Header = [String: String]
    public typealias ContentType = String

    /// The HTTP methods available for requests
    public enum Method: String {
        case get
        case post
        case delete
        case update
        case put
    }
}

// MARK: -
public extension HTTP.Header {
    /// Header field values for HTTP requests
    enum Field {
        static let urlEncoded = "application/x-www-form-urlencoded"
        static let octetStream = "application/octet-stream"
        static let contentLength = "Content-Length"
        static let contentType = "Content-Type"
        static let json = "application/json"
        static let auth = "Authorization"
        static let bearer = "Bearer %@"
        static let basic = "Basic %@"
    }
}
