//
//  TestRequest.swift
//  
//
//  Created by Viktor Gidlöf on 2022-12-06.
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
