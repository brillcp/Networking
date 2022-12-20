//
//  HTTP.swift
//  Networking
//
//  Created by Viktor Gidlöf.
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
        case put
    }
}
