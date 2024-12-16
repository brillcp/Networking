//
//  String.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

public extension String {
    /// Create a URL from the string
    /// - returns: A new URL based on the given string value
    func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw URLError(.badURL) }
        return url
    }

    /// A helper function for converting a username and password into a base64 encoded string for requests that require basic authentication
    /// - parameter password: The given password to encode with the current string
    /// - returns: A new base64 encoded string
    func basicAuthentication(password: String) -> String {
        Data("\(self):\(password)".utf8).base64EncodedString()
    }

    static func logResponse(_ value: (data: Data, response: URLResponse), printJSON: Bool) {
        guard let httpResponse = value.response as? HTTPURLResponse,
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
        if printJSON {
            print("JSON response:")
            print(value.data.prettyPrinted ?? "")
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
