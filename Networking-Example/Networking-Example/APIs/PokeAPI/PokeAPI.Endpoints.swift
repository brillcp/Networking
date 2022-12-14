//
//  PokeAPIEndpoints.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-14.
//

import Foundation
import Networking_Swift

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
        case .pokemon(let pokemon):return "pokemon/\(pokemon)"
        case .pokemons: return "pokemon"
        }
    }
}

