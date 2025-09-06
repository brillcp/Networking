//
//  MockEndpoint.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum MockEndpoint {
    case book(String)
}

// MARK: -
extension MockEndpoint: EndpointType {
    var path: String {
        switch self {
        case .book(let id): return "volumes/\(id)"
        }
    }
}
