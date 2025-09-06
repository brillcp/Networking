//
//  PokeAPIEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Networking

enum PokeAPI {
    enum Endpoint {
        case pokemon(String)
        case pokemons
    }
}

// MARK: -
extension PokeAPI.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .pokemon(let pokemon): return "pokemon/\(pokemon)"
        case .pokemons: return "pokemon"
        }
    }
}
