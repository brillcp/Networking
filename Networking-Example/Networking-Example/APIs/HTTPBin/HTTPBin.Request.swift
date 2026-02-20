import Foundation
import Networking

// MARK: - Encodable body model
extension HTTPBin {
    struct PostBody: Codable, Sendable {
        let firstName: String
        let height: Double
        let age: Int
    }
}

// MARK: - Request
extension HTTPBin {
    enum Request: Requestable, Hashable {
        case get
        case post
        case patch
        case head
        case upload
        case authGet
        case retryDemo
        case jpeg
        case png
        case download

        var encoding: Networking.Request.Encoding {
            switch self {
            case .post, .patch: return .json
            case .upload: return .multipart
            default: return .query
            }
        }

        var httpMethod: HTTP.Method {
            switch self {
            case .get, .head, .authGet, .retryDemo, .jpeg, .png, .download: return .get
            case .post, .upload: return .post
            case .patch: return .patch
            }
        }

        var parameters: HTTP.Parameters {
            switch self {
            case .get:
                return ["query": "parameter", "int": 1337]
            default:
                return HTTP.Parameters()
            }
        }

        var body: (any Encodable & Sendable)? {
            switch self {
            case .post:
                return PostBody(firstName: "Viktor", height: 6.9, age: 69)
            case .patch:
                return ["status": "updated"]
            default:
                return nil
            }
        }

        var multipartBody: MultipartFormData? {
            switch self {
            case .upload:
                var form = MultipartFormData()
                form.append(value: "Networking-Demo", name: "description")
                form.append(
                    data: "Hello from Networking!".data(using: .utf8)!,
                    name: "file",
                    fileName: "demo.txt",
                    mimeType: "text/plain"
                )
                return form
            default:
                return nil
            }
        }

        var authorization: Networking.Request.Authorization {
            switch self {
            case .authGet: return .bearer
            default: return .none
            }
        }

        var endpoint: EndpointType {
            switch self {
            case .get, .authGet: return HTTPBin.Endpoint.get
            case .post, .upload: return HTTPBin.Endpoint.post
            case .patch: return HTTPBin.Endpoint.patch
            case .head: return HTTPBin.Endpoint.head
            case .jpeg, .download: return HTTPBin.Endpoint.jpeg
            case .png: return HTTPBin.Endpoint.png
            case .retryDemo: return HTTPBin.Endpoint.status(503)
            }
        }
    }
}

// MARK: -
extension HTTPBin.Request: CaseIterable {

    static var allCases: [HTTPBin.Request] = [
        .get,
        .post,
        .patch,
        .head,
        .upload,
        .authGet,
        .retryDemo,
        .jpeg,
        .png,
        .download
    ]
}

// MARK: - Display names
extension HTTPBin.Request {
    var displayName: String {
        switch self {
        case .get: return "GET /get"
        case .post: return "POST /post (Encodable body)"
        case .patch: return "PATCH /patch"
        case .head: return "HEAD /get"
        case .upload: return "POST /post (Multipart upload)"
        case .authGet: return "GET /get (Bearer auth)"
        case .retryDemo: return "GET /status/503 (Retry demo)"
        case .jpeg: return "GET /image/jpeg"
        case .png: return "GET /image/png"
        case .download: return "Download /image/jpeg"
        }
    }
}
