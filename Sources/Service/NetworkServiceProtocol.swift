import Foundation

public protocol NetworkServiceProtocol: AnyObject {
    /// Send a request and decode the response into a data model object
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The decoded data model object
    func request<DataModel: Decodable>(_ request: Requestable, logResponse: Bool) async throws -> DataModel
    /// Send a request and return the raw response data
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The raw response data
    func data(_ request: Requestable, logResponse: Bool) async throws -> Data
    /// Send a request and return the HTTP status code
    /// - parameters:
    ///     - request: The request to send over the network
    ///     - logResponse: A boolean value that determines if the json response should be printed to the console. Defaults to false.
    /// - throws: An error if the request fails for any reason
    /// - returns: The HTTP status code
    func response(_ request: Requestable, logResponse: Bool) async throws -> HTTP.StatusCode
    /// Creates a new instance of `Network.Service.Downloader` configured with the specified URL.
    /// - Parameter url: The `URL` from which the downloader will retrieve data.
    /// - Returns: A configured `Network.Service.Downloader` instance for downloading data from the given URL.
    func downloader(url: URL) -> Network.Service.Downloader
}
