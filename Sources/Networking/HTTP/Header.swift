//
//  Header.swift
//  
//
//  Created by Viktor Gidlöf.
//

import Foundation

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
        static let accept = "Accept"
    }
}
