//
//  DefaultServer.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation

/*
/// A default server configuration for the backend
final class DefaultServer: SC {

    // MARK: Private properties
    private let tokenProvider: AuthenticationProvider

    // MARK: - Init
    init(baseURLString: String, tokenProvider: AuthenticationProvider = DefaultAuthentication()) {
        self.tokenProvider = tokenProvider
        super.init(baseURL: baseURLString.asURL())
    }

    override func header(forRequest request: Requestable) -> HTTP.Header {
        var header = super.header(forRequest: request)

        if let token = tokenProvider.token(forAuthorization: request.authorization) {
            header[HTTP.Header.Field.auth] = token
        }
        return header
    }
}

public class SC {

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func header(forRequest request: Requestable) -> HTTP.Header {
        [HTTP.Header.Field.contentType: request.contentType]
    }
}
*/
