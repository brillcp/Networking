# ⚡️ Networking

![platforms](https://img.shields.io/badge/Platforms-iOS%20macOS%20tvOS%20watchOS-blue)
![swift](https://img.shields.io/badge/Swift-5.3%2B-orange)
[![license](https://img.shields.io/github/license/brillcp/networking)](/LICENSE)
![spm](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-green)
![stars](https://img.shields.io/github/stars/brillcp/networking?style=social)

Networking is a lightweight and powerful HTTP network framework written in Swift by [Viktor Gidlöf](https://viktorgidlof.com).

- [Features](README.md#features)
- [Requirements](README.md#requirements)
- [Usage](README.md#usage)
- [Logging](README.md#logging)
- [Authentication](README.md#authentication)
- [Installation](README.md#installation)
- [License](README.md#license)

## Features
 - [x] Easily build server configurations and requests for any API
 - [x] Clear request and response logging
 - [x] URL query and JSON parameter encoding
 - [x] Simple and clean syntax
 - [x] Authentication with Basic and Bearer token
 - [x] Combine Support
 - [ ] Download Progress (coming soon…)

## Requirements
| Platform | Minimum Swift Version | Installation
| --- | --- | --- |
| iOS 13.0+ | 5.3 | [Swift Package Manager](README.md#swift-package-manager) |
| macOS 15.0+ | 5.3 | [Swift Package Manager](README.md#swift-package-manager) |
| tvOS 11.0+ | 5.3 | [Swift Package Manager](README.md#swift-package-manager) |
| watchOS 4.0+ | 5.3 | [Swift Package Manager](README.md#swift-package-manager) |

## Usage
Networking uses `Combine`, `URLSession` and `dataTaskPublishers` for network calls and is made up of three main components:

+ [`Network.Service`](Sources/Networking/Service/NetworkService.swift)
+ [`ServerConfig`](Sources/Networking/ServerConfig/ServerConfig.swift)
+ [`Requestable`](Sources/Networking/Requests/Requestable.swift)

The `Network.Service` is the main component of the framework that makes the actual requests to a backend.
It is initialzied with a server configuration that determines the API base url and any custom HTTP headers based on request parameters.

Start by creating a requestable object. Typically an `enum` that conforms to `Requestable`:
```swift
import Networking

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
1. Define what endpoint type the request should use. More about endpoint types, read below.
2. Define what type of encoding the request will use.
3. Define the HTTP method to use, in this case it's `GET`.

The `EndpointType` can be defined as an `enum` that contains all the possible endpoints for an API:
```swift
import Networking

enum Endpoint {
    case user(String)
    case repos(String)
}

extension Endpoint: EndpointType {

    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        case .repos(let username):
            return "users/\(username)/repos"
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
    let cancellable = try networkService.request(user)
        // The response data type is inferred in the result object 
        .sink { [weak self] (result: Result<GitHubUser, Error>) in
            switch result {
            case .success(let user):
                // Handle the data 
            case .failure(let error):
                // Handle error
            }
        }
catch {
    // Handle error
}
```

## Logging
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
~ /users/brillcp?limit=100
Status-Code: 200
Localized Status-Code: no error
Content-Type: application/json; charset=utf-8
```

## Authentication
Some times an API requires that requests are authenticated. Networking currently supports basic authentication and bearer token authentication. 
It involves creating a server configuration with a token provider object. The [`TokenProvider`](Sources/Networking/Protocols/TokenProvidable.swift) object can be any type of data storage, `UserDefaults`, `Keychain`, `CoreData` or other.
The point of the token provider is to persist an authentication token on the device and then use that token to authenticate requests.
The following implementation demonstrates how a bearer token can be retrieved from the device using `UserDefaults`, but as mentioned, it can be any persistant storage:
```swift
import Networking

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
enum GitHubUserRequest: Requestable {
    // ...
    var authorization: Authorization { .bearer }
}

```
This will automatically add a `"Authorization: Bearer [token]"` HTTP header to the request before sending it. Then just provide the token provider object when initializing a server configuration:
```swift
let server = ServerConfig(baseURL: "https://api.github.com", tokenProvider: TokenProvider())
```

## Installation
### Swift Package Manager
The Swift Package Manager is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
Once you have your Swift package set up, adding Networking as a dependency is as easy as adding it to the dependencies value of your Package.swift.

```
dependencies: [
    .package(url: "https://github.com/brillcp/Networking.git", .upToNextMajor(from: "1.0.0"))
]
```

## License
Networking is released under the MIT license. See [LICENSE](/LICENSE) for more details.
