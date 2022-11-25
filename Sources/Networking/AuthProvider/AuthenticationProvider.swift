//
//  AuthenticationProvider.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// A protocol for providing authentication tokens for requests
protocol AuthenticationProvider {
    /// Create an authentication token based on the requet auth method
    /// - parameter auth: The given request authentication method
    /// - returns: An optional string used to authenticate a request
    func token(forAuthorization auth: Request.Authorization) -> String?
}
