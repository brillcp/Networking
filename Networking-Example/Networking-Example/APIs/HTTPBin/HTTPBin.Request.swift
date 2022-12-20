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
        case jpeg

        var encoding: Networking_Swift.Request.Encoding {
            switch self {
            case .get, .jpeg: return .query
            case .post: return .json
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .get, .jpeg: return .get
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
            default:
                return HTTP.Parameters()
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .get: return HTTPBin.Endpoint.get
            case .post: return HTTPBin.Endpoint.post
            case .jpeg: return HTTPBin.Endpoint.jpeg
            }
        }
    }
}

// MARK: -
extension HTTPBin.Request: CaseIterable {

    static var allCases: [HTTPBin.Request] = [
        .get,
        .post,
        .jpeg
    ]
}

// MARK: -
extension HTTPBin.Request: Titleable {

    var title: String {
        switch self {
        case .get: return "Get HTTP Bin request"
        case .post: return "Post HTTP Bin request"
        case .jpeg: return "JPEG image"
        }
    }
}
