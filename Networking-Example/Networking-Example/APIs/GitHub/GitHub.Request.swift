//
//  GitHubRequest.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation
import Networking_Swift

extension GitHub {
    enum Request: Requestable, Hashable {
        case user(String)
        case search(String)
        case emojis
        case repos(String)

        var encoding: Networking_Swift.Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

        var parameters: HTTP.Parameters {
            switch self {
            case .search(let query): return ["q": query]
            default: return HTTP.Parameters()
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .repos(let username): return GitHub.Endpoint.repos(username)
            case .user(let username): return GitHub.Endpoint.user(username)
            case .search: return GitHub.Endpoint.search
            case .emojis: return GitHub.Endpoint.emojis
            }
        }
    }
}

// MARK: -
extension GitHub.Request: CaseIterable {

    static var allCases: [GitHub.Request] = [
        .user("brillcp"),
        .repos("brillcp"),
        .search("Apple"),
        .emojis
    ]
}

// MARK: -
extension GitHub.Request: Titleable {

    var title: String {
        switch self {
        case .search(let query): return "Search user \"\(query)\""
        case .user(let user): return "Get user \"\(user)\""
        case .repos: return "Get user repos"
        case .emojis: return "Get Emojis"
        }
    }
}
