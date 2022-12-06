//
//  TestRequest.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum TestRequest: Requestable {
    case user(String)

    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }
    var endpoint: EndpointType {
        switch self {
        case .user(let username): return TestEndpoint.user(username)
        }
    }
}
