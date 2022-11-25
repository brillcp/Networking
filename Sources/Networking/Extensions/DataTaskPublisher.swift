//
//  DataTaskPublisher.swift
//  BeReal
//
//  Created by Viktor Gidlöf on 2022-11-15.
//

import Foundation
import Combine

extension URLSession.DataTaskPublisher {
    /// Log the incoming response to the console
    /// - parameter printJSON: A bool value that determines if the json respons is also printed to the console. Defaults to true.
    /// - returns: The current publisher in the pipeline
    func logResponse(printJSON: Bool = true) -> Publishers.HandleEvents<Self> {
        handleEvents(receiveOutput: { value in
            guard let httpResponse = value.response as? HTTPURLResponse,
                  let url = httpResponse.url?.absoluteString,
                  let comps = URLComponents(string: url),
                  let host = comps.host
            else { return }

            Swift.print("♻️ Incoming response from \(host) @ \(Date())")

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

            Swift.print(printOutput)
            if printJSON {
                Swift.print("JSON response:")
                Swift.print(value.data.prettyPrinted ?? "")
            }
        })
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
