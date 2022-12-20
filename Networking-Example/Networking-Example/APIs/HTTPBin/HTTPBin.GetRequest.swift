//
//  HTTPBin.GetRequest.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

extension HTTPBin {
    enum GetRequest: Requestable, Hashable {
        case get

        var encoding: Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

        var parameters: HTTP.Parameters {
            switch self {
            case .get: return ["query": "parameter", "int": 1337]
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .get: return HTTPBin.Endpoint.get
            }
        }
    }
}

// MARK: -
extension HTTPBin.GetRequest: CaseIterable {

    static var allCases: [HTTPBin.GetRequest] = [
        .get
    ]
}

// MARK: -
extension HTTPBin.GetRequest: Titleable {

    var title: String {
        switch self {
        case .get: return "Get HTTP Bin request"
        }
    }
}
