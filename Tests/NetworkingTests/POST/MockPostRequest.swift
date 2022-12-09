//
//  MockPostRequest.swift
//  
//
//  Created by Viktor Gidlöf on 2022-12-09.
//

import Foundation
import Networking

enum MockPostRequest: Requestable {
    case user(MockPostUserModel)

    var endpoint: EndpointType { MockEndpoint.users }
    var encoding: Request.Encoding { .json }
    var httpMethod: HTTP.Method { .post }

    var parameters: HTTP.Parameters {
        switch self {
        case .user(let model):
            return model.asParameters()
        }
    }
}
