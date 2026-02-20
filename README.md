![network-header](https://user-images.githubusercontent.com/15960525/206866384-044ca1d7-172d-4d5f-80f7-7ee234f2a363.png)
![workflow](https://img.shields.io/github/actions/workflow/status/brillcp/networking/swift.yml?branch=master&event=push)
![release](https://img.shields.io/github/v/release/brillcp/networking)
![swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![platforms](https://img.shields.io/badge/Platforms-iOS%20macOS%20tvOS%20watchOS-blue)
[![spm](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-green)](#swift-package-manager)
[![license](https://img.shields.io/github/license/brillcp/networking)](/LICENSE)
![stars](https://img.shields.io/github/stars/brillcp/networking?style=social)

Networking is a lightweight and powerful HTTP network framework written in Swift by [Viktor Gidlöf](https://viktorgidlof.com). It uses `async/await` and `URLSession` for network calls and can be used as a network layer for any REST API on `iOS`, `macOS`, `watchOS` and `tvOS`.

- [Features](#features)
- [Requirements](#requirements-%EF%B8%8F)
- [Usage](#usage-)
- [Logging](#logging-)
- [Advanced usage](#advanced-usage)
    - [Authentication](#authentication)
        - [JWT token refresh](#jwt-token-refresh)
    - [Adding parameters](#adding-parameters)
    - [Parameter encoding](#parameter-encoding)
    - [Making POST requests](#making-post-requests)
    - [Encodable bodies](#encodable-bodies)
    - [Converting data models](#converting-data-models)
    - [Check HTTP status codes](#check-HTTP-status-codes)
    - [Full response metadata](#full-response-metadata)
    - [Interceptors](#interceptors)
    - [Multipart uploads](#multipart-uploads)
    - [Retry policy](#retry-policy)
    - [Download progress](#download-progress)
    - [Upload progress](#upload-progress)
- [Installation](#installation-)
    - [Swift Package Manager](#swift-package-manager)
- [Sample code](#sample-code-)
- [Contribution](#contribution-)
- [License](#license-)

## Features 📲
 - [x] Easy to build server configurations and requests for any REST API
 - [x] Clear request and response logging
 - [x] URL query, JSON, and form-encoded parameter encoding
 - [x] Type-safe `Encodable` request bodies
 - [x] Authentication with Basic and Bearer token
 - [x] Automatic JWT token refresh via interceptors
 - [x] Full response metadata (status code + headers) via `HTTP.Response`
 - [x] Request interceptors and middleware
 - [x] Multipart form data uploads
 - [x] Retry policy with exponential backoff
 - [x] Download files with progress
 - [x] Upload files with progress
 - [x] Simple and clean syntax
 - [x] Swift 6 concurrency support

## Requirements ❗️
| Platform | Min. Swift Version | Installation
| --- | --- | --- |
| iOS 16.4+ | 5.9 | [Swift Package Manager](#swift-package-manager) |
| macOS 10.15+ | 5.9 | [Swift Package Manager](#swift-package-manager) |
| tvOS 13.0+ | 5.9 | [Swift Package Manager](#swift-package-manager) |
| watchOS 6.0+ | 5.9 | [Swift Package Manager](#swift-package-manager) |

## Usage 🕹
Networking is built around three core components:
- [`Network.Service`](Sources/Service/NetworkService.swift)
- [`ServerConfig`](Sources/ServerConfig/ServerConfig.swift)
- [`Requestable`](Sources/Protocols/Requestable.swift)

The `Network.Service` is the main component of the framework that makes the actual requests to a backend.
It is initialized with a server configuration that determines the API base url and any custom HTTP headers based on request parameters.

Start by creating a requestable object. Typically an `enum` that conforms to `Requestable`:
```swift
enum GitHubUserRequest: Requestable {
    case user(String)

    // 1.
    var endpoint: EndpointType {
        switch self {
        case .user(let username):
            return Endpoint.user(username)
        }
    }
    // 2.
    var encoding: Request.Encoding { .query }
    // 3.
    var httpMethod: HTTP.Method { .get }
}
```
1. Define what endpoint type the request should use. More about endpoint types below.
2. Define what type of encoding the request will use.
3. Define the HTTP method to use.

The [`EndpointType`](Sources/Protocols/EndpointType.swift) can be defined as an `enum` that contains all the possible endpoints for an API:
```swift
enum Endpoint {
    case user(String)
    case repos(String)
    // ...
}

extension Endpoint: EndpointType {

    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        case .repos(let username):
            return "users/\(username)/repos"
        // ...
        }
    }
}
```

Then simply create a server configuration and a new network service and make a request:
```swift
let serverConfig = ServerConfig(baseURL: "https://api.github.com")
let networkService = Network.Service(server: serverConfig)
let user = GitHubUserRequest.user("brillcp")

do {
    let result: GitHubUser = try await networkService.request(user)
    // Handle the data
catch {
    // Handle error
}
```

## Logging 📝
Every request is logged to the console by default. This is an example of an outgoing request log:
```
⚡️ Outgoing request to api.github.com @ 2022-12-05 16:58:25 +0000
GET /users/brillcp?foo=bar
Header: {
    Content-Type: application/json
}

Body: {}

Parameters: {
    foo=bar
}
```

This is how the incoming responses are logged:
```
♻️ Incoming response from api.github.com @ 2022-12-05 16:58:32 +0000
~ /users/brillcp?foo=bar
Status-Code: 200
Localized Status-Code: no error
Content-Type: application/json; charset=utf-8
```
There is also a way to log the pure JSON response for requests in the console. By passing `printJSONResponse: true` when making a request, the response JSON will be logged in the console. That way it is easy to debug when modeling an API:
```swift
let model = try await networkService.request(user, printJSONResponse: true)
```

## Advanced usage
### Authentication
Some times an API requires that requests are authenticated. Networking currently supports basic authentication and bearer token authentication.
It involves creating a server configuration with a token provider object. The [`TokenProvider`](Sources/Protocols/TokenProvidable.swift) object can be any type of data storage, `UserDefaults`, `Keychain`, `CoreData` or other.
The point of the token provider is to persist an authentication token on the device and then use that token to authenticate requests.
The following implementation demonstrates how a bearer token can be retrieved from the device using `UserDefaults`, but as mentioned, it can be any persistant storage:
```swift
final class TokenProvider {
    private static let tokenKey = "com.example.ios.jwt.key"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}

extension TokenProvider: TokenProvidable {
    var token: Result<String, TokenProvidableError> {
        guard let token = defaults.string(forKey: Self.tokenKey) else { return .failure(.missing) }
        return .success(token)
    }

    func setToken(_ token: String) {
        defaults.set(token, forKey: Self.tokenKey)
    }

    func reset() {
        defaults.set(nil, forKey: Self.tokenKey)
    }
}
```

In order to use this authentication token just implement the `authorization` property on the requests that require authentication:
```swift
enum AuthenticatedRequest: Requestable {
    // ...
    var authorization: Authorization { .bearer }
}

```
This will automatically add a `"Authorization: Bearer [token]"` HTTP header to the request before sending it. Then just provide the token provider object when initializing a server configuration:
```swift
let server = ServerConfig(baseURL: "https://api.github.com", tokenProvider: TokenProvider())
```

#### JWT token refresh
When a JWT expires the server responds with a `401 Unauthorized`. You can use an [interceptor](#interceptors) to automatically refresh the token and retry the request. The framework re-builds the request on each retry attempt, so the refreshed token from your `TokenProvider` is picked up automatically:
```swift
struct JWTRefreshInterceptor: NetworkInterceptor {
    let tokenProvider: TokenProvider

    func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool {
        // Only retry once on 401
        guard case .badServerResponse(.unauthorized, _) = error, attemptCount == 0 else {
            return false
        }

        // Call your refresh endpoint
        let newToken = try await refreshToken()
        tokenProvider.setToken(newToken)

        // Return true — the request is rebuilt with the new token and retried
        return true
    }

    private func refreshToken() async throws -> String {
        let url = URL(string: "https://api.example.com/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        return response.accessToken
    }
}
```

Pass it as an interceptor when creating the service:
```swift
let tokenProvider = TokenProvider()
let server = ServerConfig(baseURL: "https://api.example.com", tokenProvider: tokenProvider)
let service = Network.Service(server: server, interceptors: [JWTRefreshInterceptor(tokenProvider: tokenProvider)])
```

### Adding parameters
Adding parameters to a request is done by implementing the `parameters` property on a request:
```swift
enum Request: Requestable {
    case getData(String)

    // ...
    var parameters: HTTP.Parameters {
        switch self {
        case .getData(let username):
            return [
                "page": 1,
                "username": username
            ]
        }
    }
}
```

### Parameter encoding
Depedning on the `encoding` method, the parameters will either be encoded in the url query, in the HTTP body as JSON or as a string.
The `encoding` property on a request will encode the given parameters either in the url query or the HTTP body.
```swift
var encoding: Request.Encoding { .query }      // Encode parameters in the url: `.../users?page=1&username=viktor`
var encoding: Request.Encoding { .json }       // Encode parameters as JSON in the HTTP body: `{"page":"1,"name":"viktor"}"`
var encoding: Request.Encoding { .body }       // Encode parameters as a string in the HTTP body: `"page=1&name=viktor"`
var encoding: Request.Encoding { .multipart }  // Encode using multipart/form-data (see Multipart uploads below)
```

### Making `POST` requests
Making post requests to a backend API is done by setting the `httpMethod` property to `.post` and provide parameters:
```swift
enum PostRequest: Requestable {
    case postData(String)

    // ...
    var httpMethod: HTTP.Method { .post }

    var parameters: HTTP.Parameters {
        switch self {
        case .postData(let username):
            return ["page": 1, "username": username]
        }
    }
}
```

### Encodable bodies
For type-safe request bodies, use the `body` property instead of `parameters`. This encodes a `Codable` struct directly as JSON in the HTTP body:
```swift
struct CreateUser: Codable, Sendable {
    let name: String
    let age: Int
}

enum UserRequest: Requestable {
    case create(CreateUser)

    var endpoint: EndpointType { Endpoint.users }
    var encoding: Request.Encoding { .json }
    var httpMethod: HTTP.Method { .post }

    var body: (any Encodable & Sendable)? {
        switch self {
        case .create(let user):
            return user
        }
    }
}
```
When `body` is provided with `.json` encoding, it takes priority over `parameters`.

### Converting data models
> **Deprecated:** Prefer using the `body` property (see [Encodable bodies](#encodable-bodies)) for sending data models in requests.

If you have a custom data model that conforms to `Codable` you can use [`.asParameters()`](Sources/Extensions/Encodable.swift#L13) to convert the data model object to `HTTP Parameters`:
```swift
struct User: Codable {
    let name: String
    let age: Int
}

let user = User(name: "Günther", age: 69)
let parameters = user.asParameters()
print(parameters) // ["name": "Günther", "age": "69"]
```

### Check HTTP status codes
Sometimes it can be useful to just check for a HTTP status code when a response comes back. Use [`response`](Sources/Service/NetworkService.swift#L66) to send a request and get back the status code in the response:
```swift
let usersRequest = ...
let responseCode = try await networkService.response(usersRequest)
print(responseCode == .ok)
```
Networking supports all the status codes defined in the HTTP protocol, [see here](Sources/HTTP/StatusCode.swift).

### Full response metadata
Use `send()` to get the full response including the decoded body, HTTP status code, and response headers:
```swift
let request = GitHubUserRequest.user("brillcp")

// Decoded model with metadata
let response: HTTP.Response<GitHubUser> = try await networkService.send(request)
print(response.body)       // The decoded GitHubUser
print(response.statusCode) // .ok
print(response.headers)    // ["Content-Type": "application/json", ...]

// Raw data with metadata
let dataResponse: HTTP.Response<Data> = try await networkService.send(request)
print(dataResponse.body)       // Raw Data
print(dataResponse.statusCode) // .ok
```

### Interceptors
Interceptors allow you to adapt outgoing requests and control retry behavior. Create a type conforming to [`NetworkInterceptor`](Sources/Protocols/NetworkInterceptor.swift):
```swift
struct AuthInterceptor: NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = try await fetchToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func retry(_ request: URLRequest, dueTo error: Network.Service.NetworkError, attemptCount: Int) async throws -> Bool {
        // Retry once on 401 after refreshing the token
        if case .badServerResponse(.unauthorized, _) = error, attemptCount == 0 {
            try await refreshToken()
            return true
        }
        return false
    }
}
```

Pass interceptors when creating the network service:
```swift
let service = Network.Service(server: serverConfig, interceptors: [AuthInterceptor()])
```
Interceptors are called in order. `adapt` runs before each request attempt, and `retry` is consulted when a request fails.

### Multipart uploads
For file uploads and mixed content, use multipart form data encoding:
```swift
enum UploadRequest: Requestable {
    case avatar(Data)

    var endpoint: EndpointType { Endpoint.upload }
    var encoding: Request.Encoding { .multipart }
    var httpMethod: HTTP.Method { .post }

    var multipartBody: MultipartFormData? {
        switch self {
        case .avatar(let imageData):
            var form = MultipartFormData()
            form.append(value: "profile", name: "type")
            form.append(data: imageData, name: "file", fileName: "avatar.jpg", mimeType: "image/jpeg")
            return form
        }
    }
}
```
The `MultipartFormData` builder handles boundary generation and encoding automatically.

### Retry policy
[`RetryPolicy`](Sources/Service/RetryPolicy.swift) is a built-in interceptor that retries failed requests with exponential backoff:
```swift
let retryPolicy = RetryPolicy(
    maxRetryCount: 3,
    retryableStatusCodes: RetryPolicy.defaultRetryableStatusCodes, // 408, 429, 500, 502, 503, 504
    retryOnNetworkError: true,
    baseDelay: 1.0 // seconds, doubles on each retry
)

let service = Network.Service(server: serverConfig, interceptors: [retryPolicy])
```
You can combine it with other interceptors:
```swift
let service = Network.Service(server: serverConfig, interceptors: [AuthInterceptor(), retryPolicy])
```

### Download progress

You can download files and track progress asynchronously using the [`Downloader`](Sources/Service/Downloader.swift). Call `start()` to get a `DownloadHandle` with progress stream, completion task, and cancellation:
```swift
let url = URL(string: "https://example.com/file.zip")!

let downloader = networkService.downloader(url: url)
let handle = await downloader.start()

// Track download progress
for await progress in handle.progress {
    print("Download progress: \(progress * 100)%")
}

do {
    // Await the final file URL
    let fileURL = try await handle.finished.value
    print("Download completed at: \(fileURL)")
} catch {
    print("Download failed: \(error)")
}

// Cancel if needed
handle.cancel()
```

### Upload progress

For uploads that need progress tracking, use the [`Uploader`](Sources/Service/Uploader.swift). Build it from a `Requestable` and call `start()` to get an `UploadHandle`:
```swift
let uploader = try await networkService.uploader(for: uploadRequest)
let handle = await uploader.start()

// Track upload progress
for await progress in handle.progress {
    print("Upload progress: \(progress * 100)%")
}

do {
    // Await the server response
    let responseData = try await handle.finished.value
    print("Upload completed: \(String(data: responseData, encoding: .utf8) ?? "")")
} catch {
    print("Upload failed: \(error)")
}

// Cancel if needed
handle.cancel()
```
The `Uploader` uses `URLSessionUploadTask` under the hood and reports byte-level progress via its delegate. The request must use `.multipart` encoding with a `multipartBody` (see [Multipart uploads](#multipart-uploads)).

## Installation 💾
### Swift Package Manager
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding Networking as a dependency is as easy as adding it to the dependencies value of your Package.swift.
```
dependencies: [
    .package(url: "https://github.com/brillcp/Networking.git", .upToNextMajor(from: "0.9.13"))
]
```

## Sample code 📱
The sample project is a small application that demonstrates some of the functionality of the framework. Start by cloning the repo:
```
git clone https://github.com/brillcp/Networking.git
```
Open `Networking-Example.xcodeproj` and run.

## Contribution 🛠
- [Create an issue](https://github.com/brillcp/networking/issues/new) if you:
    - Are struggling or have any questions
    - Want to improve the framework

- [Create a PR](https://github.com/brillcp/Networking/compare) if you:
    - Find a bug
    - Find a documentation typo

## License 🏛
Networking is released under the MIT license. See [LICENSE](/LICENSE) for more details.
