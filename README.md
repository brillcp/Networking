# Networking ⚡️

Networking is a lightweight but powerful HTTP network framework written in Swift by [Viktor Gidlöf](https://viktorgidlof.com).

## Features
 - [x] URL query / JSON Parameter Encoding
 - [x] Combine Support
 - [x] Authentication with Basic and Bearer token
 - [x] HTTP Response Validation
 - [ ] Download Progress Closures


## Usage
It uses `Combine`, `URLSession` and `dataTaskPublishers` for network calls and is made up of three components:

+ [`Network.Service`](Sources/Networking/Service/NetworkService.swift)
+ [`ServerConfig`](Sources/Networking/ServerConfig/ServerConfig.swift)
+ [`Requestable`](Sources/Networking/Requests/Requestable.swift)

The `Network.Service` is the main component of the framework that makes the actual requests to a backend.
It is initialzied with a server configuration that determines the API base url and any custom HTTP headers based on request parameters.

Start by creating a `Requestable` object. Typlically an `enum`:
```swift
enum GithubUser: Requestable {
    case user(String)

    var endpoint: EndpointType { Endpoint.githubUsers }
    var encoding: Request.Encoding { .query }
    var httpMethod: HTTP.Method { .get }
}
```
