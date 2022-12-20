//
//  HTTPBinEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-20.
//

import Foundation
import Networking_Swift

enum HTTPBin {
    enum Endpoint {
        case get
        case post
        case jpeg
        case png
    }
}

// MARK: -
extension HTTPBin.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .get: return "get"
        case .post: return "post"
        case .jpeg: return "image/jpeg"
        case .png: return "image/png"
        }
    }
}
