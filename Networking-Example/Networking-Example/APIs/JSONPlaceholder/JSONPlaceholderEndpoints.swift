import Networking

enum JSONPlaceholder {
    enum Endpoint {
        case users
        case posts
    }
}

// MARK: -
extension JSONPlaceholder.Endpoint: EndpointType {

    var path: String {
        switch self {
        case .users: return "users"
        case .posts: return "posts"
        }
    }
}
