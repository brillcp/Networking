import Testing
import Foundation
@testable import Networking

struct UploaderTests {
    @Test
    func uploadCompletesWithResponseData() async throws {
        let server = ServerConfig(baseURL: try "https://httpbin.org".asURL())
        let service = Network.Service(server: server)

        let request = MockUploadRequest()
        let uploader = try await service.uploader(for: request)
        let handle = await uploader.start()

        let data = try await handle.finished.value
        let responseString = String(data: data, encoding: .utf8) ?? ""

        // httpbin.org/post echoes back the uploaded data
        #expect(!data.isEmpty)
        #expect(responseString.contains("hello from uploader"))
    }

    @Test
    func uploadProgressEmitsValues() async throws {
        let server = ServerConfig(baseURL: try "https://httpbin.org".asURL())
        let service = Network.Service(server: server)

        let request = MockUploadRequest()
        let uploader = try await service.uploader(for: request)
        let handle = await uploader.start()

        var progressValues: [Float] = []
        for await progress in handle.progress {
            progressValues.append(progress)
        }

        // Should have at least the initial 0.0 yield
        #expect(!progressValues.isEmpty)
        #expect(progressValues.first == 0.0)
    }
}

// MARK: - Mock

private enum MockUploadEndpoint: EndpointType {
    case post
    var path: String { "post" }
}

private struct MockUploadRequest: Requestable {
    var encoding: Request.Encoding { .multipart }
    var httpMethod: HTTP.Method { .post }
    var endpoint: EndpointType { MockUploadEndpoint.post }

    var multipartBody: MultipartFormData? {
        var form = MultipartFormData()
        form.append(value: "hello from uploader", name: "message")
        form.append(
            data: Data(repeating: 0xAB, count: 1024),
            name: "file",
            fileName: "test.bin",
            mimeType: "application/octet-stream"
        )
        return form
    }
}
