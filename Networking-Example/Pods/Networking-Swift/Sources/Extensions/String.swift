//
//  String.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

public extension String {
    /// Create a URL from the string
    /// - returns: A new URL based on the given string value
    func asURL() -> URL {
        guard let url = URL(string: self) else { fatalError("The URL could not be created ❌ This should never happen!") }
        return url
    }

    /// A helper function for converting a username and password into a base64 encoded string for requests that require basic authentication
    /// - parameter password: The given password to encode with the current string
    /// - returns: A new base64 encoded string
    func basicAuthentication(password: String) -> String {
        Data("\(self):\(password)".utf8).base64EncodedString()
    }
}
