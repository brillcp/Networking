//
//  JSONPlaceholder.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

extension JSONPlaceholder {
    enum Request: Requestable, Hashable {
        case users
        case posts

        var encoding: Networking_Swift.Request.Encoding {
            switch self {
            case .users: return .query
            case .posts: return .json
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .users, .posts: return .get
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .users: return JSONPlaceholder.Endpoint.users
            case .posts: return JSONPlaceholder.Endpoint.posts
            }
        }
    }
}

// MARK: -
extension JSONPlaceholder.Request: CaseIterable {

    static var allCases: [JSONPlaceholder.Request] = [
        .users,
        .posts
    ]
}

// MARK: -
extension JSONPlaceholder.Request: Titleable {

    var title: String {
        switch self {
        case .users: return "Get mock users"
        case .posts: return "Get mock posts"
        }
    }
}
