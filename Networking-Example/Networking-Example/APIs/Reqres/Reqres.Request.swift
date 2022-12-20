//
//  Reqres.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

extension Reqres {
    enum Request: Requestable, Hashable {
        case users(page: Int)
        case user(id: Int)

        var encoding: Networking_Swift.Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

        var parameters: HTTP.Parameters {
            switch self {
            case .users(let page): return ["page": page]
            default: return HTTP.Parameters()
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .users: return Reqres.Endpoint.users
            case .user(let id): return Reqres.Endpoint.user(id: id)
            }
        }
    }
}

// MARK: -
extension Reqres.Request: CaseIterable {

    static var allCases: [Reqres.Request] = [
        .user(id: 3),
        .users(page: 2)
    ]
}

// MARK: -
extension Reqres.Request: Titleable {

    var title: String {
        switch self {
        case .users: return "List users"
        case .user: return "Get user"
        }
    }
}
