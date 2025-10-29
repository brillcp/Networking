import Foundation

/// A lightweight logging interface for network activity.
///
/// Conformers provide implementations to record outgoing requests and incoming responses.
/// Use this protocol to abstract logging so it can be swapped or disabled in different builds.
public protocol NetworkLoggerProtocol {
    /// Logs an outgoing network request before it is sent.
    /// - Parameter request: The request to be logged, including URL, method, headers, and body if present.
    func logRequest(_ request: URLRequest)
    /// Logs an incoming network response after it is received.
    /// - Parameters:
    ///   - data: The raw response payload returned by the server.
    ///   - response: The URL response containing status code and headers.
    func logResponse(_ data: Data, _ response: URLResponse)
}

// MARK: - 
public struct NetworkLogger: NetworkLoggerProtocol {
    public init() {}

    public func logRequest(_ request: URLRequest) {
        guard let url = request.url?.absoluteString,
              let components = URLComponents(string: url),
              let method = request.httpMethod,
              let host = components.host
        else { return }

        print("⚡️ Outgoing request to \(host) @ \(Date())")

        let query = components.query ?? ""
        let parameters = query.split(separator: "&")
        let questionmark = parameters.isEmpty ? "" : "?"
        var output = "\(method) \(components.path)\(questionmark)\(query)\n"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            output += "Header: {\n"
            headers.forEach { output += "\t\($0): \($1)\n" }
            output += "}\n\n"
        } else {
            output += "Header: {}\n"
        }

        if let body = request.httpBody, let json = try? JSONSerialization.jsonObject(with: body) as? HTTP.Parameters {
            output += "Body: {\n"
            json.forEach { output += "\t\($0)\n" }
            output += "}\n"
        } else {
            output += "Body: {}\n"
        }

        if !parameters.isEmpty {
            output += "Parameters: {\n"
            parameters.forEach { output += "\t\($0)\n" }
            output += "}\n"
        } else {
            output += "Parameters: {}\n"
        }

        print(output)
        print("\n")
    }

    public func logResponse(_ data: Data, _ response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse,
              let url = httpResponse.url?.absoluteString,
              let comps = URLComponents(string: url),
              let host = comps.host
        else { return }

        print("♻️ Incoming response from \(host) @ \(Date())")

        let statusCode = httpResponse.statusCode
        let statusCodeString = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let path = comps.path

        var printOutput = "~ \(path)\n"
        printOutput += "Status-Code: \(statusCode)\n"
        printOutput += "Localized Status-Code: \(statusCodeString)\n"

        httpResponse.allHeaderFields.forEach { key, value in
            if key.description == HTTP.Header.Field.contentLength || key.description == HTTP.Header.Field.contentType {
                printOutput += "\(key): \(value)\n"
            }
        }

        print(printOutput)
        if let json = data.prettyPrinted {
            print("JSON response:")
            print(json)
        }
    }
}

// MARK: -
private extension Data {
    /// Convert data into an optional pretty printed json string.
    var prettyPrinted: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
