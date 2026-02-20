import Testing
import Foundation
@testable import Networking

struct MultipartFormDataTests {
    private let server = ServerConfig(baseURL: try! "https://api.example.com".asURL())

    @Test
    func encodesTextAndFilePartsWithCorrectBoundaryStructure() {
        var form = MultipartFormData(boundary: "test-boundary")
        form.append(value: "Viktor", name: "username")
        form.append(data: Data("file-content".utf8), name: "avatar", fileName: "photo.jpg", mimeType: "image/jpeg")

        let encoded = form.encode()
        let body = String(data: encoded, encoding: .utf8)!

        // Text part
        #expect(body.contains("Content-Disposition: form-data; name=\"username\""))
        #expect(body.contains("Viktor"))

        // File part
        #expect(body.contains("Content-Disposition: form-data; name=\"avatar\"; filename=\"photo.jpg\""))
        #expect(body.contains("Content-Type: image/jpeg"))
        #expect(body.contains("file-content"))

        // Boundary structure
        #expect(body.contains("--test-boundary\r\n"))
        #expect(body.contains("--test-boundary--\r\n"))
    }

    @Test
    func multipartRequestSetsCorrectContentTypeHeader() throws {
        let request = MockMultipartRequest()
        let urlRequest = try request.configure(withServer: server, using: NetworkLogger())

        let contentType = try #require(urlRequest.value(forHTTPHeaderField: "Content-Type"))
        #expect(contentType.hasPrefix("multipart/form-data; boundary="))
        #expect(urlRequest.httpBody != nil)
    }
}

// MARK: - Mocks

private enum MockUploadEndpoint: EndpointType {
    case upload
    var path: String { "upload" }
}

private struct MockMultipartRequest: Requestable {
    var encoding: Request.Encoding { .multipart }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockUploadEndpoint.upload }

    var multipartBody: MultipartFormData? {
        var form = MultipartFormData()
        form.append(value: "test", name: "field")
        form.append(data: Data("binary".utf8), name: "file", fileName: "test.bin", mimeType: "application/octet-stream")
        return form
    }
}
