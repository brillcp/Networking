//
//  TokenProvider.swift
//  Networking
//
//  Created by Viktor Gidlöf on 2022-11-29.
//

import Foundation

/// An error enum for the token provider
public enum TokenProviderError: Error {
    case missing
}

// MARK: -
/// A protocol for getting and setting JWT tokens
public protocol TokenProvider: AnyObject {
    /// The JWT token for the logged in user
    var token: Result<String, TokenProviderError> { get }
    /// Persist the given token to `UserDefaults` (could be any persistant storage)
    /// - parameter token: The token to persist
    func setToken(_ token: String)
    /// Remove the token from the persistant storage
    func reset()
}
