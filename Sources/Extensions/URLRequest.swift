import Foundation

public enum EncodingError: LocalizedError {
    case malformedURLComponents
    case missingURL
}

// MARK: -
public extension URLRequest {
    /// Init a new `URLRequest` from a `Request.Config` object
    /// - parameter config: The configuration object to use for the setup of the request
    init(withConfig config: Request.Config) throws {
        self.init(url: config.url)
        timeoutInterval = config.timeoutInterval
        httpMethod = config.httpMethod.rawValue
        allHTTPHeaderFields = config.header

        switch config.encoding {
        case .query:
            let parameters = config.parameters
            guard !parameters.isEmpty else { return }
            try urlEncode(withParameters: parameters)

        case .json:
            if let encodedBody = config.encodedBody {
                httpBody = encodedBody
                setValue(HTTP.Header.Field.json, forHTTPHeaderField: HTTP.Header.Field.contentType)
                setValue(HTTP.Header.Field.json, forHTTPHeaderField: HTTP.Header.Field.accept)
            } else {
                let parameters = config.parameters
                guard !parameters.isEmpty else { return }
                try jsonEncode(withParameters: parameters)
            }

        case .body:
            let parameters = config.parameters
            guard !parameters.isEmpty else { return }
            bodyEncode(withParameters: parameters)
        }
    }
}

// MARK: - Private encoding functions
private extension URLRequest {
    /// Encode the parameters in the url query
    /// - parameter parameters: The parameters to encode
    /// - throws: An error if request can't be encoded
    /// - returns: The new `URLRequest` with the parameters encoded as a query in the url
    mutating func urlEncode(withParameters parameters: HTTP.Parameters) throws {
        guard let url else { throw EncodingError.missingURL }
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
    }

    /// Encode the parameters in the http body of the request as JSON
    /// - parameter parameters: The parameters to encode
    /// - returns: The new `URLRequest` with the parameters encoded as JSON in the http body
    mutating func jsonEncode(withParameters parameters: HTTP.Parameters) throws {
        httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        setValue(HTTP.Header.Field.json, forHTTPHeaderField: HTTP.Header.Field.contentType)
        setValue(HTTP.Header.Field.json, forHTTPHeaderField: HTTP.Header.Field.accept)
    }

    /// Encode the parameters in the http body of the request as a form-urlencoded string. E.g `"foo=bar&baz=qux"`
    /// - parameter parameters: The parameters to encode
    /// - returns: The new `URLRequest` with the parameters encoded in the http body as a percent-encoded string
    mutating func bodyEncode(withParameters parameters: HTTP.Parameters) {
        let allowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: "+=&"))
        let parameterString = parameters.map { key, value in
            let encodedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: allowed) ?? "\(key)"
            let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: allowed) ?? "\(value)"
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        httpBody = parameterString.data(using: .utf8)

        if value(forHTTPHeaderField: HTTP.Header.Field.contentType) == nil {
            setValue(HTTP.Header.Field.urlEncoded, forHTTPHeaderField: HTTP.Header.Field.contentType)
        }
    }
}
