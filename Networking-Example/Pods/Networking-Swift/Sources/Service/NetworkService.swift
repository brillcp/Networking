//
//  NetworkService.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Combine

public let name = "Networking"
public let version = "0.8.9"

public enum Network {
    /// A network service object used to make requests to the backend.
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
        private func dataTaskPublisher(_ request: Requestable, logResponse: Bool) throws -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
            let config = Request.Config(request: request, server: server)
            let urlRequest = try URLRequest(withConfig: config)
            urlRequest.log()

            return session.dataTaskPublisher(for: urlRequest)
                .logResponse(printJSON: logResponse)
                .receive(on: RunLoop.main)
                .tryMap { $0 }
                .eraseToAnyPublisher()
        }
    }
}

// MARK: -
public extension Network.Service {
    /// Create a new publisher that contains a decoded data model object
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the given data model object or an error
    func request<DataModel: Decodable>(_ request: Requestable, logResponse: Bool = false) throws -> AnyPublisher<DataModel, Error> {
        try dataPublisher(request, logResponse: logResponse)
            .decode(type: DataModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that contains the response data
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with the data or an error
    func dataPublisher(_ request: Requestable, logResponse: Bool = false) throws -> AnyPublisher<Data, Error> {
        try dataTaskPublisher(request, logResponse: logResponse)
            .map(\.data)
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that contains the HTTP status code
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the data task publisher fails for any reason
    /// - returns: A new publisher with a bool value that determines if the request succeeded
    func responsePublisher(_ request: Requestable, logResponse: Bool = false) throws -> AnyPublisher<HTTP.StatusCode, Error> {
        try dataTaskPublisher(request, logResponse: logResponse)
            .compactMap { $0.response as? HTTPURLResponse }
            .map { HTTP.StatusCode(rawValue: $0.statusCode) ?? .unknown }
            .eraseToAnyPublisher()
    }

    /// Create a new publisher that publishes file download progress and the destination of the temporary file
    /// - parameter url: The URL to the file to download
    /// - returns: A new download publisher with the file download progress and destination URL
    func downloadPublisher(url: URL) -> Network.Service.Downloader {
        Network.Service.Downloader(url: url)
    }
}
