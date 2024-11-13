//
//  NetworkService.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Combine

public let name = "Networking"
public let version = "0.9.0"

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
    }
}

// MARK: - Public functions
public extension Network.Service {
    /// Send a request and decode the response into a data model object
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The decoded data model object
    func request<DataModel: Decodable>(_ request: Requestable, logResponse: Bool = false) async throws -> DataModel {
        let (data, _) = try await makeDataRequest(request, logResponse: logResponse)
        return try decoder.decode(DataModel.self, from: data)
    }

    /// Send a request and return the raw response data
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The raw response data
    func data(_ request: Requestable, logResponse: Bool = false) async throws -> Data {
        let (data, _) = try await makeDataRequest(request, logResponse: logResponse)
        return data
    }

    /// Send a request and return the HTTP status code
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The HTTP status code
    func response(_ request: Requestable, logResponse: Bool = false) async throws -> HTTP.StatusCode {
        let (_, response) = try await makeDataRequest(request, logResponse: logResponse)
        guard let httpResponse = response as? HTTPURLResponse else { return .unknown }
        return HTTP.StatusCode(rawValue: httpResponse.statusCode) ?? .unknown
    }

    /// Creates a new instance of `Network.Service.Downloader` configured with the specified URL.
    /// - Parameter url: The `URL` from which the downloader will retrieve data.
    /// - Returns: A configured `Network.Service.Downloader` instance for downloading data from the given URL.
    func downloader(url: URL) -> Network.Service.Downloader {
        Network.Service.Downloader(url: url)
    }
}

// MARK: - Private functions
private extension Network.Service {
    func makeDataRequest(_ request: Requestable, logResponse: Bool) async throws -> (Data, URLResponse) {
        let urlRequest = try request.configure(withServer: server)
        let (data, response) = try await session.data(for: urlRequest)
        if logResponse {
            String.logResponse((data, response), printJSON: logResponse)
        }
        return (data, response)
    }
}
