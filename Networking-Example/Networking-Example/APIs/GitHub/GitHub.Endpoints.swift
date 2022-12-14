//
//  GitHubEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation
import Networking_Swift

enum GitHub {
    enum Endpoint {
        case user(String)
        case emojis
        case search
        case repos(String)
    }
}

// MARK: -
extension GitHub.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        case .emojis:
            return "emojis"
        case .search:
            return "search/users"
        case .repos(let username):
            return "users/\(username)/repos"
        }
    }
}
