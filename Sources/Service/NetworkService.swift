//
//  NetworkService.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

public let name = "Networking"
public let version = "0.9.3"

public enum Network {
    /// A network service object used to make requests to the backend.
    public class Service {
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
extension Network.Service: NetworkServiceProtocol {
    public func request<DataModel: Decodable>(_ request: Requestable, logResponse: Bool = true) async throws -> DataModel {
        let (data, _) = try await makeDataRequest(request, logResponse: logResponse)
        return try decoder.decode(DataModel.self, from: data)
    }

    public func data(_ request: Requestable, logResponse: Bool = false) async throws -> Data {
        let (data, _) = try await makeDataRequest(request, logResponse: logResponse)
        return data
    }

    public func response(_ request: Requestable, logResponse: Bool = false) async throws -> HTTP.StatusCode {
        let (_, response) = try await makeDataRequest(request, logResponse: logResponse)
        guard let httpResponse = response as? HTTPURLResponse else { return .unknown }
        return HTTP.StatusCode(rawValue: httpResponse.statusCode) ?? .unknown
    }

    public func downloader(url: URL) -> Network.Service.Downloader {
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

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badServerResponse(-1)
        }

        guard (HTTP.StatusCode.ok.rawValue ... HTTP.StatusCode.iMUsed.rawValue).contains(httpResponse.statusCode) else {
            throw NetworkError.badServerResponse(httpResponse.statusCode)
        }

        return (data, response)
    }
}

public extension Network.Service {
    enum NetworkError: LocalizedError {
        case invalidURL
        case badServerResponse(Int)
        case decodingError(Error)
        case networkError(Error)

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                "Invalid URL"
            case .badServerResponse(let code):
                "Server returned status code: \(code)"
            case .decodingError(let error):
                "Failed to decode data: \(error.localizedDescription)"
            case .networkError(let error):
                "Network error: \(error.localizedDescription)"
            }
        }
    }

}
