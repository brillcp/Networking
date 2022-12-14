//
//  APIListData.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation
import Networking_Swift

struct APIListData {
    let id = UUID()
    let name: String
    let url: String
    let endpoints: [AnyHashable]
}

extension APIListData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension APIListData: Equatable {

    static func == (lhs: APIListData, rhs: APIListData) -> Bool {
        lhs.id == rhs.id
    }
}
