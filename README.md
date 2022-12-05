# ⚡️ Networking

Networking is a lightweight and powerful HTTP network framework written in Swift by [Viktor Gidlöf](https://viktorgidlof.com).

## Features
 - [x] Simple syntax
 - [x] Clear request and response console logging
 - [x] URL query / JSON Parameter Encoding
 - [x] Authentication with Basic and Bearer token
 - [x] HTTP Response Validation
 - [x] Combine Support
 - [ ] Download Progress Closures


## Usage
Networking uses `Combine`, `URLSession` and `dataTaskPublishers` for network calls and is made up of three main components:

+ [`Network.Service`](Sources/Networking/Service/NetworkService.swift)
+ [`ServerConfig`](Sources/Networking/ServerConfig/ServerConfig.swift)
+ [`Requestable`](Sources/Networking/Requests/Requestable.swift)

The `Network.Service` is the main component of the framework that makes the actual requests to a backend.
It is initialzied with a server configuration that determines the API base url and any custom HTTP headers based on request parameters.

Start by creating a requestable object. Typlically an `enum` that conforms to `Requestable`:
```swift
enum GithubUserRequest: Requestable {
    case user(String)

    // 1.
    var endpoint: EndpointType { Endpoint.githubUsers }
    
    // 2.
    var encoding: Request.Encoding { .query }
    
    // 3.
    var httpMethod: HTTP.Method { .get }
}
```
1. Define what endpoint type this request should use
2. Define what type of encoding the request will use (`query` will encode the `parameters` in the URL for instance)
3. Define the HTTP method to use, in this case it's `GET`

The `EndpointType` can be defined with an enum that contains all the possible endpoints for the API:
```swift
enum Endpoint {
    case user(String)
}

extension Endpoint: EndpointType {

    var path: String {
        switch self {
        case .user(let username):
            return "users/\(username)"
        }
    }
}
```

Then simply create a server configuration and a new network service and make a request:
```swift
let serverConfig = ServerConfig(baseURL: "https://api.github.com")
let networkService = Network.Service(server: serverConfig)

let request = GithubUserRequest.user("brillcp")

do {
    let cancellable = try networkService.request(request).sink { [weak self] (result: Result<GithubUser, Error>) in
        switch result {
        case .success(let user):
            // Handle the data 
        case .failure(let error):
            // Handle error
            print(error.localizedDescription)
        }
    }
catch {
    // Handle error
}
```








