//
//  HTTPBin.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking

extension HTTPBin {
    enum Request: Requestable, Hashable {
        case get
        case post
        case jpeg
        case png

        var encoding: Networking.Request.Encoding {
            switch self {
            case .get, .jpeg, .png: return .query
            case .post: return .json
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .get, .jpeg, .png: return .get
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
            case .png: return HTTPBin.Endpoint.png
            }
        }
    }
}

// MARK: -
extension HTTPBin.Request: CaseIterable {

    static var allCases: [HTTPBin.Request] = [
        .get,
        .post,
        .jpeg,
        .png
    ]
}
