//
//  APIListData.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation

struct APIListData {
    let id = UUID()
    let url: URL
    let endpoints: [AnyHashable]
}

// MARK: -
extension APIListData {
    var name: String? { url.host }
}

// MARK: -
extension APIListData: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: -
extension APIListData {

    static var github: APIListData {
        APIListData(url: "https://api.github.com".asURL(), endpoints: GitHub.GetRequest.allCases)
    }

    static var pokeAPI: APIListData {
        APIListData(url: "https://pokeapi.co/api/v2".asURL(), endpoints: PokeAPI.GetRequest.allCases)
    }

    static var httpBin: APIListData {
        APIListData(url: "https://httpbin.org".asURL(), endpoints: HTTPBin.Request.allCases)
    }

    static var placeholder: APIListData {
        APIListData(url: "https://jsonplaceholder.typicode.com".asURL(), endpoints: JSONPlaceholder.Request.allCases)
    }

    static var reqres: APIListData {
        APIListData(url: "https://reqres.in/api".asURL(), endpoints: Reqres.Request.allCases)
    }
}
