//
//  MockGetRequest.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum MockGetRequest: Requestable {
    case book(String)

    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }

    var endpoint: EndpointType {
        switch self {
        case .book(let id): return MockEndpoint.book(id)
        }
    }
}
