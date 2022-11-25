//
//  DefaultAuthentication.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

enum CredentialKey {
    static let username = "ios.beReal.username.key"
    static let password = "ios.beReal.password.key"
}

// MARK: -
/// A default implementation for request authenticaltion
struct DefaultAuthentication {

    // MARK: Private properties
    private let userDefaults: UserDefaults

    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}

// MARK: -
extension DefaultAuthentication: AuthenticationProvider {

    func token(forAuthorization auth: Request.Authorization) -> String? {
        switch auth {
        case .basic:
            guard let username = userDefaults.string(forKey: CredentialKey.username),
                  let password = userDefaults.string(forKey: CredentialKey.password)
            else { return nil }
            let baseEncodedString = Data("\(username):\(password)".utf8).base64EncodedString()
            return String(format: HTTP.Header.Field.basic, baseEncodedString)
        case .bearer(token: let token):
            return String(format: HTTP.Header.Field.bearer, token)
        case .none:
            return nil
        }
    }
}
