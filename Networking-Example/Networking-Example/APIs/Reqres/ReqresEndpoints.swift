//
//  ReqresEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

enum Reqres {
    enum Endpoint {
        case users
        case user(id: Int)
    }
}

// MARK: -
extension Reqres.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .users: return "users"
        case .user(let id): return "users/\(id)"
        }
    }
}
