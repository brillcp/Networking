//
//  String.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

extension String {

    static let urlFailed = "The URL could not be created ❌ This should never happen!"

    /// Create a URL from the string
    /// - returns: A new URL based on the given string value
    func asURL() -> URL {
        guard let url = URL(string: self) else { fatalError(.urlFailed) }
        return url
    }
}
