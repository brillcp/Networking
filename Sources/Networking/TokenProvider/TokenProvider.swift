//
//  TokenProvider.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// An error enum for the token provider
public enum TokenProviderError: Error {
    case missing
}

// MARK: -
/// A protocol for getting and setting JWT tokens
public protocol TokenProvider: AnyObject {
    /// A result object containing a token used in HTTP Authorization request headers
    var token: Result<String, TokenProviderError> { get }
    /// Persist the given token to any persistant storage on device. E.g `UserDefaults`, `CoreData`, `Keychain`.
    /// - parameter token: The token to persist
    func setToken(_ token: String)
    /// Remove the token from the persistant storage
    func reset()
}
