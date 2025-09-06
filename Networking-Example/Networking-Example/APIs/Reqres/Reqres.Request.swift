import Networking

extension Reqres {
    enum Request: Requestable, Hashable {
        case users(page: Int)
        case user(id: Int)
        case register(email: String, password: String)

        var encoding: Networking.Request.Encoding {
            switch self {
            case .register: return .json
            default: return .query
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .register: return .post
            default: return .get
            }
        }

        var parameters: HTTP.Parameters {
            switch self {
            case .users(let page): return ["page": page]
            case .register(let email, let password): return ["email": email, "password": password]
            default: return HTTP.Parameters()
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .users: return Reqres.Endpoint.users
            case .user(let id): return Reqres.Endpoint.user(id: id)
            case .register: return Reqres.Endpoint.register
            }
        }
    }
}

// MARK: -
extension Reqres.Request: CaseIterable {

    static var allCases: [Reqres.Request] = [
        .users(page: 2),
        .user(id: 3),
        .register(email: "eve.holt@reqres.in", password: "pistol")
    ]
}
