//
//  URLRequest.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

public enum EncodingError: LocalizedError {
    case malformedURLComponents
    case missingURL
}

// MARK: -
public extension URLRequest {
    /// Init a new `URLRequest` from a `RequestBuilder.Config` object
    /// - parameter requestConfig: The configuration object to use for the setup of the request
    init(withConfig config: Request.Config) {
        self.init(url: config.url)
        timeoutInterval = config.timeoutInterval
        httpMethod = config.httpMethod.rawValue
        allHTTPHeaderFields = config.header
    }

    /// Encode the parameters in the http body of the request as JSON
    /// - parameter parameters: The parameters to encode
    /// - throws: An error if request can't be encoded
    /// - returns: The new `URLRequest` with the parameters encoded as a query in the url
    mutating func urlEncode(withParameters parameters: HTTP.Parameters) throws -> URLRequest {
        guard let url = url else { throw EncodingError.missingURL }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw EncodingError.malformedURLComponents }

        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }

        if components.queryItems == nil {
            components.queryItems = queryItems
        } else {
            components.queryItems?.append(contentsOf: queryItems)
        }

        self.url = components.url

        if value(forHTTPHeaderField: HTTP.Header.Field.contentType) == nil {
            setValue(HTTP.Header.Field.urlEncoded, forHTTPHeaderField: HTTP.Header.Field.contentType)
        }
        return self
    }

    /// Encode the parameters in the http body of the request as JSON
    /// - parameter parameters: The parameters to encode
    /// - returns: The new `URLRequest` with the parameters encoded as JSON in the http body
    mutating func jsonEncode(withParameters parameters: HTTP.Parameters) throws -> URLRequest {
        httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        setValue(HTTP.Header.Field.json, forHTTPHeaderField: HTTP.Header.Field.contentType)
        return self
    }

    /// Print outgoing request information to the console
    func log() {
        guard let url = url?.absoluteString, let components = URLComponents(string: url), let method = httpMethod, let host = components.host else { return }

        print("⚡️ Outgoing request to \(host) @ \(Date())")

        let query = components.query ?? ""
        let parameters = query.split(separator: "&")
        let questionmark = parameters.isEmpty ? "" : "?"
        var output = "\(method) \(components.path)\(questionmark)\(query)\n"

        if let headers = allHTTPHeaderFields {
            output += "Header: {\n"
            headers.forEach { output += "\t\($0): \($1)\n" }
            output += "}\n\n"
        }

        if let body = httpBody, let json = try? JSONSerialization.jsonObject(with: body) as? HTTP.Parameters {
            output += "Body: {\n"
            json.forEach { output += "\t\($0)\n" }
            output += "}\n"
        }

        if !parameters.isEmpty {
            output += "Parameters: {\n"
            parameters.forEach { output += "\t\($0)\n" }
            output += "}\n"
        }

        print(output)
        print("\n")
    }
}
