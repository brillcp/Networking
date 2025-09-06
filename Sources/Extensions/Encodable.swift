import Foundation

public extension Encodable {
    /// Convert an encodable object to a `HTTP.Parameters` dictionary
    /// - returns: The object as a HTTP parameter dictionary
    func asParameters() -> HTTP.Parameters {
        guard let data = try? JSONEncoder().encode(self) else { return [:] }
        guard let parameters = try? JSONSerialization.jsonObject(with: data) as? HTTP.Parameters else { return [:] }
        return parameters
    }
}
