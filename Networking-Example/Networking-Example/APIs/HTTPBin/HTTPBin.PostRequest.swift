//
//  HTTPBin.PostRequest.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

extension HTTPBin {

    enum PostRequest: Requestable, Hashable {
        case post

        var encoding: Request.Encoding { .json }
        var httpMethod: HTTP.Method { .post }

        var parameters: HTTP.Parameters {
            switch self {
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
            case .post: return HTTPBin.Endpoint.post
            }
        }
    }
}

// MARK: -
extension HTTPBin.PostRequest: CaseIterable {

    static var allCases: [HTTPBin.PostRequest] = [
        .post
    ]
}

// MARK: -
extension HTTPBin.PostRequest: Titleable {

    var title: String {
        switch self {
        case .post: return "Post HTTP Bin request"
        }
    }
}
