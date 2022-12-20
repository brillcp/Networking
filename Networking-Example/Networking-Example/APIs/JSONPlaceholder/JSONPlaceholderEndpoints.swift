//
//  JSONPlaceholderEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

enum JSONPlaceholder {
    enum Endpoint {
        case users
        case posts
    }
}

// MARK: -
extension JSONPlaceholder.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .users: return "users"
        case .posts: return "posts"
        }
    }
}
