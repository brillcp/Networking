//
//  TokenProvidable.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// An error enum for the token provider
public enum TokenProvidableError: Error {
    case missing
}

// MARK: -
/// A protocol for creating token providable objects. It can be tokens for basic request authentication or bearer tokens.
public protocol TokenProvidable: AnyObject {
    /// A result object containing a token used in HTTP Authorization request headers
    var token: Result<String, TokenProvidableError> { get }
    /// Persist the given token to any persistant storage on device. E.g `UserDefaults`, `CoreData`, `Keychain`.
    /// - parameter token: The token to persist
    func setToken(_ token: String)
    /// Remove the token from the persistant storage
    func reset()
}
