import Foundation

public extension URL {
    /// Creat a `[String: String]` dictionary from the query parameters of a URL
    /// - returns: A new dictionary with the query items
    func queryParameters() -> [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems
        else { return [:] }
        return queryItems.reduce(into: [String: String]()) { (result, item) in result[item.name] = item.value }
    }
}
