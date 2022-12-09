//
//  MockUserModel.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

struct MockUsersRepsonse: Decodable {
    let data: [MockUserModel]
}

// MARK: -
struct MockUserResponse: Decodable {
    let data: MockUserModel
}

// MARK: -
struct MockUserModel: Decodable {
    let id: Int
    let firstName: String

    enum CodingKeys: String, CodingKey {
        case data
        case id
        case firstName = "first_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
    }
}
