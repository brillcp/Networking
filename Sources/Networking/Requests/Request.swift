//
//  Request.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

/// A name space for request encoding and autorization
public enum Request {
    /// Encoding types for parameters for requests
    public enum Encoding {
        /// Encode parameters in the URL of a request. E.g `.../api/v1/endpoint?foo=bar`
        case query
        /// Encode parameters in the http body as json
        case json
        /// Encode parameters in the http body as a string
        case body
    }

    /// The different authorization types for a given request
    public enum Authorization {
        case bearer(token: String)
        case basic
        case none
    }
}
