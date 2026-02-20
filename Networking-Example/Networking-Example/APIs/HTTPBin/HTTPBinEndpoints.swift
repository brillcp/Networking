import Networking

enum HTTPBin {
    enum Endpoint {
        case get
        case post
        case patch
        case head
        case jpeg
        case png
        case status(Int)
    }
}

// MARK: -
extension HTTPBin.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .get: return "get"
        case .post: return "post"
        case .patch: return "patch"
        case .head: return "get"
        case .jpeg: return "image/jpeg"
        case .png: return "image/png"
        case .status(let code): return "status/\(code)"
        }
    }
}
