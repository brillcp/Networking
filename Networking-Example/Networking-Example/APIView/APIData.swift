//
//  APIData.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation

struct APIData: Hashable {
    let id = UUID()
    let name: String
    let url: String
}
