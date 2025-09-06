//
//  GitHubEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum GitHub {
    enum Endpoint {
        case user(String)
        case search
        case repos(String)
    }
}

// MARK: -
extension GitHub.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .repos(let username): return "users/\(username)/repos"
        case .user(let username):return "users/\(username)"
        case .search: return "search/users"
        }
    }
}
