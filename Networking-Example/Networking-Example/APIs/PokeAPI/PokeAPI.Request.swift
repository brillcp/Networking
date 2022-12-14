//
//  PokeAPI.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation
import Networking_Swift

extension PokeAPI {

    enum Request: Requestable, Hashable {
        case pokemon(String)
        case pokemons

        var encoding: Networking_Swift.Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

        var parameters: HTTP.Parameters {
            switch self {
            case .pokemons: return ["limit": "150"]
            default: return HTTP.Parameters()
            }
        }
        var endpoint: EndpointType {
            switch self {
            case .pokemon(let pokemon): return PokeAPI.Endpoint.pokemon(pokemon)
            case .pokemons: return PokeAPI.Endpoint.pokemons
            }
        }
    }
}

// MARK: -
extension PokeAPI.Request: CaseIterable {

    static var allCases: [PokeAPI.Request] = [
        .pokemon("pikachu"),
        .pokemons
    ]
}

// MARK: -
extension PokeAPI.Request: Titleable {

    var title: String {
        switch self {
        case .pokemon(let pokemon): return "Get Pokemon \"\(pokemon)\""
        case .pokemons: return "Get all Pokemon"
        }
    }
}
