import Foundation
import Networking

/// A simple in-memory token provider for demo purposes.
/// HTTPBin echoes the Authorization header back, so you can see it in the response.
final class InMemoryTokenProvider: TokenProvidable {
    private var storedToken: String?

    var token: Result<String, TokenProvidableError> {
        guard let storedToken else { return .failure(.missing) }
        return .success(storedToken)
    }

    init(token: String? = nil) {
        self.storedToken = token
    }

    func setToken(_ token: String) {
        storedToken = token
    }

    func reset() {
        storedToken = nil
    }
}
