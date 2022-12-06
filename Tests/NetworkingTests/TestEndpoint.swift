//
//  TestEndpoint.swift
//  
//
//  Created by Viktor Gidlöf on 2022-12-06.
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
