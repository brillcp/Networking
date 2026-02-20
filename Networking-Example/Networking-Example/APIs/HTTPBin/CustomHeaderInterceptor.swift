import Foundation
import Networking

/// An example interceptor that adds a custom header to every request.
/// HTTPBin echoes all headers back, so you can verify it in the response.
struct CustomHeaderInterceptor: NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        request.setValue("Networking-Demo", forHTTPHeaderField: "X-Custom-Header")
        return request
    }
}
