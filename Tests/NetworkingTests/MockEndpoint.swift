//
//  MockEndpoint.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum MockEndpoint {
    case users
    case user(Int)
}

// MARK: -
extension MockEndpoint: EndpointType {

    var path: String {
        switch self {
        case .users: return "users"
        case .user(let id): return "users/\(id)"
        }
    }
}
