//
//  JSONPlaceholder.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking

extension JSONPlaceholder {
    enum Request: Requestable, Hashable {
        case users
        case posts

        var encoding: Networking.Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

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
