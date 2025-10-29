import Foundation

public enum Package {
    public static let name = "Networking"
    public static let version = "0.9.9"

    public static var description: String {
        "\(name)/\(version)"
    }
}

// MARK: - NetworkServiceProtocol
public protocol NetworkServiceProtocol {
    /// Send a request and decode the response into a data model object
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to true.
    /// - throws: An error if the request fails for any reason
    /// - returns: The decoded data model object
    func request<DataModel: Decodable>(_ request: Requestable, logResponse: Bool) async throws -> DataModel
    /// Send a request and return the raw response data
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to true.
    /// - throws: An error if the request fails for any reason
    /// - returns: The raw response data
    func data(_ request: Requestable, logResponse: Bool) async throws -> Data
    /// Send a request and return the HTTP status code
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to true.
    /// - throws: An error if the request fails for any reason
    /// - returns: The HTTP status code
    func response(_ request: Requestable, logResponse: Bool) async throws -> HTTP.StatusCode
    /// Creates a new instance of `Network.Service.Downloader` configured with the specified URL.
    /// - Parameter url: The `URL` from which the downloader will retrieve data.
    /// - Returns: A configured `Network.Service.Downloader` instance for downloading data from the given URL.
    func downloader(url: URL) -> Network.Service.Downloader
}

// MARK: - Network service
public enum Network {
    /// A network service object used to make requests to the backend.
    public actor Service {
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
        ///     - dateDecodingStrategy: The strategy used by the JSONDecoder to decode date values from responses. Defaults to `.iso8601`.
        public init(
            server: ServerConfig,
            session: URLSession = .shared,
            decoder: JSONDecoder = JSONDecoder(),
            dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
        ) {
            let configuredDecoder = decoder
            configuredDecoder.dateDecodingStrategy = dateDecodingStrategy
            self.decoder = configuredDecoder
            self.session = session
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

    public func data(_ request: Requestable, logResponse: Bool = true) async throws -> Data {
        let (data, _) = try await makeDataRequest(request, logResponse: logResponse)
        return data
    }

    public func response(_ request: Requestable, logResponse: Bool = true) async throws -> HTTP.StatusCode {
        let (_, response) = try await makeDataRequest(request, logResponse: logResponse)
        guard let httpResponse = response as? HTTPURLResponse else { return .unknown }
        return HTTP.StatusCode(rawValue: httpResponse.statusCode) ?? .unknown
    }

    nonisolated
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

// MARK: - Public network error
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
