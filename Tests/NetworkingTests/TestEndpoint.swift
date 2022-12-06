//
//  TestEndpoint.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum TestEndpoint {
    case user(String)
}

// MARK: -
extension TestEndpoint: EndpointType {

    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        }
    }
}
