//
//  NetworkService.swift
//  Networking
//
//  Created by Viktor Gidlöf.
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
        private func dataTaskPublisher(_ request: Requestable, logRequest: Bool, logResponse: Bool) throws -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
            try session.dataTaskPublisher(for: request.config(withServer: server, logResponse: logResponse))
                .logResponse(printJSON: logResponse)
                .receive(on: RunLoop.main)
                .tryMap { $0 }
                .eraseToAnyPublisher()
        }
    }
}

// MARK: -
public extension Network.Service {
    /// Create a new publisher that contains the response data
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logRequest: A boolean value that determines if the request data should be printed to the console. Defaults to false.
    ///     - printResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the data or an error
    func dataPublisher(_ request: Requestable, logRequest: Bool = false, logResponse: Bool = false) throws -> AnyPublisher<Data, Error> {
        try dataTaskPublisher(request, logRequest: logRequest, logResponse: logResponse)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that contains a decoded data model object
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logRequest: A boolean value that determines if the request data should be printed to the console. Defaults to false.
    ///     - printResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the given data model object or an error
    func request<DataModel: Decodable>(_ request: Requestable, logRequest: Bool = false, logResponse: Bool = false) throws -> AnyPublisher<DataModel, Error> {
        try dataTaskPublisher(request, logRequest: logRequest, logResponse: logResponse)
            .map(\.data)
            .decode(type: DataModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that contains a bool value if the HTTP response status code succeeds with code 200 ..< 300
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logRequest: A boolean value that determines if the request data should be printed to the console. Defaults to false.
    ///     - printResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with a bool value that determines if the request succeeded
    func responsePublisher(_ request: Requestable, logRequest: Bool = false, logResponse: Bool = false) throws -> AnyPublisher<Bool, Error> {
        try dataTaskPublisher(request, logRequest: logRequest, logResponse: logResponse)
            .compactMap { $0.response as? HTTPURLResponse }
            .map { 200 ..< 300 ~= $0.statusCode }
            .eraseToAnyPublisher()
    }
}
