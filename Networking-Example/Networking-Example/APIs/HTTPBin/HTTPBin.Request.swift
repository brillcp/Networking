//
//  HTTPBin.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

extension HTTPBin {
    enum Request: Requestable, Hashable {
        case get
        case post

        var encoding: Networking_Swift.Request.Encoding {
            switch self {
            case .get: return .query
            case .post: return .json
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .get: return .get
            case .post: return .post
            }
        }

        var parameters: HTTP.Parameters {
            switch self {
            case .get:
                return ["query": "parameter", "int": 1337]
            case .post:
                return [
                    "firstName": "Viktor",
                    "height": 6.9,
                    "age": 69
                ]
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .get: return HTTPBin.Endpoint.get
            case .post: return HTTPBin.Endpoint.post
            }
        }
    }
}

// MARK: -
extension HTTPBin.Request: CaseIterable {

    static var allCases: [HTTPBin.Request] = [
        .get,
        .post
    ]
}

// MARK: -
extension HTTPBin.Request: Titleable {

    var title: String {
        switch self {
        case .get: return "Get HTTP Bin request"
        case .post: return "Post HTTP Bin request"
        }
    }
}
