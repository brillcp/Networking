//
//  APIListData.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation

struct APIListData {
    let id = UUID()
    let name: String
    let url: String
    let endpoints: [AnyHashable]
}

// MARK: -
extension APIListData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
