//
//  PokeAPI.Request.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking_Swift

extension PokeAPI {

    enum GetRequest: Requestable, Hashable {
        case pokemon(String)
        case pokemons

        var encoding: Request.Encoding { .query }
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
extension PokeAPI.GetRequest: CaseIterable {

    static var allCases: [PokeAPI.GetRequest] = [
        .pokemon("pikachu"),
        .pokemons
    ]
}

// MARK: -
extension PokeAPI.GetRequest: Titleable {

    var title: String {
        switch self {
        case .pokemon(let pokemon): return "Get Pokemon \"\(pokemon)\""
        case .pokemons: return "Get all Pokemon"
        }
    }
}
