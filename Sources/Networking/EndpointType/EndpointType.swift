//
//  Endpoints.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

/// A protocol for an endpoint type. Usually an enum with all the possible endpoints as cases.
/// And the `path` property implemented in an extension to provide the exact endpoint values.
public protocol EndpointType {
    /// The backend API endpoint path. E.g `/data/id`
    var path: String { get }
}
