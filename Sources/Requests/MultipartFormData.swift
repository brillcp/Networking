import Foundation

/// A builder for constructing `multipart/form-data` request bodies.
///
/// Use this type to assemble text fields and file data into a single HTTP body
/// suitable for file uploads and form submissions.
///
/// ```swift
/// var form = MultipartFormData()
/// form.append(value: "Viktor", name: "username")
/// form.append(data: imageData, name: "avatar", fileName: "photo.jpg", mimeType: "image/jpeg")
/// ```
public struct MultipartFormData: Sendable {
    private let boundary: String
    private var parts: [Part] = []

    /// The `Content-Type` header value for this multipart body, including the boundary.
    public var contentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    /// Append a text field to the form data.
    /// - Parameters:
    ///   - value: The string value of the field.
    ///   - name: The field name.
    public mutating func append(value: String, name: String) {
        parts.append(.text(name: name, value: value))
    }

    /// Append file data to the form data.
    /// - Parameters:
    ///   - data: The raw file data.
    ///   - name: The field name.
    ///   - fileName: The file name to include in the `Content-Disposition` header.
    ///   - mimeType: The MIME type of the file (e.g. `"image/jpeg"`, `"application/pdf"`).
    public mutating func append(data: Data, name: String, fileName: String, mimeType: String) {
        parts.append(.file(name: name, fileName: fileName, mimeType: mimeType, data: data))
    }

    /// Encode all parts into the final `multipart/form-data` body.
    /// - Returns: The encoded body data ready to be set as `httpBody`.
    public func encode() -> Data {
        var body = Data()
        let crlf = "\r\n"

        for part in parts {
            body.append("--\(boundary)\(crlf)")

            switch part {
            case .text(let name, let value):
                body.append("Content-Disposition: form-data; name=\"\(name)\"\(crlf)")
                body.append(crlf)
                body.append(value)
                body.append(crlf)

            case .file(let name, let fileName, let mimeType, let data):
                body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\(crlf)")
                body.append("Content-Type: \(mimeType)\(crlf)")
                body.append(crlf)
                body.append(data)
                body.append(crlf)
            }
        }

        body.append("--\(boundary)--\(crlf)")
        return body
    }
}

// MARK: - Private

private extension MultipartFormData {
    enum Part: Sendable {
        case text(name: String, value: String)
        case file(name: String, fileName: String, mimeType: String, data: Data)
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
