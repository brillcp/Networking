import Networking

extension GitHub {
    enum GetRequest: Requestable, Hashable {
        case user(String)
        case search(String)
        case repos(String)

        var encoding: Request.Encoding { .query }
        var httpMethod: HTTP.Method { .get }

        var parameters: HTTP.Parameters {
            switch self {
            case .search(let query): return ["q": query]
            default: return HTTP.Parameters()
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .repos(let username): return GitHub.Endpoint.repos(username)
            case .user(let username): return GitHub.Endpoint.user(username)
            case .search: return GitHub.Endpoint.search
            }
        }
    }
}

// MARK: -
extension GitHub.GetRequest: CaseIterable {

    static var allCases: [GitHub.GetRequest] = [
        .user("brillcp"),
        .repos("brillcp"),
        .search("Apple")
    ]
}
