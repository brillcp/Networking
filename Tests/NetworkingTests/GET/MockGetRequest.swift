//
//  MockGetRequest.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum MockGetRequest: Requestable {
    case user(Int)
    case users

    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }

    var endpoint: EndpointType {
        switch self {
        case .user(let username): return MockEndpoint.user(username)
        case .users: return MockEndpoint.users
        }
    }
}
