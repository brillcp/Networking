//
//  APIListData.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

struct APIListData: Identifiable {
    let id = UUID()
    let url: URL
    let endpoints: [Requestable]
}

// MARK: -
extension APIListData {
    var name: String? { url.host }
}

// MARK: -
extension APIListData: Hashable {
    static func == (lhs: APIListData, rhs: APIListData) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: -
extension APIListData {

    static var github: APIListData {
        APIListData(url: try! "https://api.github.com".asURL(), endpoints: GitHub.GetRequest.allCases)
    }

    static var pokeAPI: APIListData {
        APIListData(url: try! "https://pokeapi.co/api/v2".asURL(), endpoints: PokeAPI.GetRequest.allCases)
    }

    static var httpBin: APIListData {
        APIListData(url: try! "https://httpbin.org".asURL(), endpoints: HTTPBin.Request.allCases)
    }

    static var placeholder: APIListData {
        APIListData(url: try! "https://jsonplaceholder.typicode.com".asURL(), endpoints: JSONPlaceholder.Request.allCases)
    }

    static var reqres: APIListData {
        APIListData(url: try! "https://reqres.in/api".asURL(), endpoints: Reqres.Request.allCases)
    }
}
