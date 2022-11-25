//
//  NetworkService.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation
import Combine

public enum Network {
    /// The main network service used to make requests to the backend.
    public final class Service {
        // MARK: Private properties
        private let server: ServerConfig
        private let decoder: JSONDecoder
        private let session: URLSession

        // MARK: - Init
        /// Initialize the network service
        /// - parameters:
        ///     - server: The given server configuration
        ///     - session: The given URLSession object. Defaults to the shared instance.
        ///     - decoder: A default json decoder object
        public init(server: ServerConfig, session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
            self.session = session
            self.decoder = decoder
            self.server = server
        }

        // MARK: - Private functions
        private func dataTaskPublisher(_ request: Requestable) throws -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
            try session.dataTaskPublisher(for: request.config(with: server))
                .logResponse(printJSON: false)
                .receive(on: RunLoop.main)
                .tryMap { $0 }
                .eraseToAnyPublisher()
        }
    }
}

// MARK: -
public extension Network.Service {
    /// Create a new publisher that makes a request to the backend
    /// - parameter request: The request to send over the network
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the data or an error
    func dataPublisher(_ request: Requestable) throws -> AnyPublisher<Data, Error> {
        try dataTaskPublisher(request)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that makes a request to the backend
    /// - parameter request: The request to send over the network
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the given data model object or an error
    func request<DataModel: Decodable>(_ request: Requestable) throws -> AnyPublisher<DataModel, Error> {
        try dataTaskPublisher(request)
            .map(\.data)
            .decode(type: DataModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Create a publisher that contains a bool value if the request succeeds with code 200 ..< 300
    /// - parameter request: The request to send over the network
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with a bool value that determines if the request succeeded
    func responsePublisher(_ request: Requestable) throws -> AnyPublisher<Bool, Error> {
        try dataTaskPublisher(request)
            .compactMap { $0.response as? HTTPURLResponse }
            .map { 200 ..< 300 ~= $0.statusCode }
            .eraseToAnyPublisher()
    }
}
