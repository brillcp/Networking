import Networking

enum Reqres {
    enum Endpoint {
        case users
        case user(id: Int)
        case register
    }
}

// MARK: -
extension Reqres.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .users: return "users"
        case .user(let id): return "users/\(id)"
        case .register: return "register"
        }
    }
}
