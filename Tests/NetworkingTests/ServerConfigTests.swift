//
//  ServerConfigTests.swift
//  Networking
//
//  Created by VG on 2024-11-13.
//

import Testing
import Foundation
@testable import Networking

struct ServerConfigTests {
    private let validURLString: URL = try! "https://api.example.com".asURL()
    private let tokenProviderMock = MockTokenProvider()
    private var config: ServerConfig

    init() {
        self.config = ServerConfig(baseURL: validURLString, tokenProvider: tokenProviderMock)
    }

    // MARK: - Initialization Tests
    @Test
    func initializationWithValidURLShouldSucceed() {
        let config = ServerConfig(baseURL: validURLString, userAgent: "TestAgent/1.0")
        #expect(config.baseURL == validURLString)
        #expect(config.userAgent == "TestAgent/1.0")
    }

    // MARK: - Header Generation Tests
    @Test
    func headerGenerationIncludesBaseHeaders() {
        let request = MockRequestable(authorization: .none)
        let headers = config.header(forRequest: request)
        #expect(headers[HTTP.Header.Field.host] == config.baseURL.host)
    }
    
    @Test
    func headerGenerationIncludesAdditionalHeaders() {
        let additionalHeaders = ["X-Custom-Header": "CustomValue"]
        let config = ServerConfig(baseURL: validURLString, additionalHeaders: additionalHeaders)
        let headers = config.header(forRequest: MockRequestable(authorization: .none))
        #expect(headers["X-Custom-Header"] == "CustomValue")
    }

    @Test
    func headerGenerationWithBearerTokenIncludesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .success("sampleToken")
        let request = MockRequestable(authorization: .bearer)
        let headers = config.header(forRequest: request)
        #expect(headers[HTTP.Header.Field.auth] == "Bearer sampleToken")
    }

    @Test
    func headerGenerationWithBasicTokenIncludesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .success("sampleToken")
        let request = MockRequestable(authorization: .basic)
        let headers = config.header(forRequest: request)
        #expect(headers[HTTP.Header.Field.auth] == "Basic sampleToken")
    }

    @Test
    func headerGenerationWithTokenProviderFailureExcludesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .failure(.missing)
        let request = MockRequestable(authorization: .bearer)
        let headers = config.header(forRequest: request)
        #expect(headers[HTTP.Header.Field.auth] == nil)
    }

    // MARK: - Convenience Initializers Tests
    @Test
    func basicInitializerCreatesConfigurationWithDefaultValues() {
        let config = ServerConfig.basic(baseURL: validURLString)
        #expect(config.baseURL == validURLString)
        #expect(config.tokenProvider == nil)
    }

    @Test
    func authenticatedInitializerCreatesConfigurationWithTokenProvider() {
        let config = ServerConfig.authenticated(baseURL: validURLString, tokenProvider: tokenProviderMock)
        #expect(config.baseURL == validURLString)
        #expect(config.tokenProvider != nil)
    }
}

// MARK: - Mocks

private class MockTokenProvider: TokenProvidable {
    var tokenResult: Result<String, TokenProvidableError> = .failure(.missing)
    var token: Result<String, TokenProvidableError> { tokenResult }

    func setToken(_ token: String) {}
    func reset() {}
}

private struct MockRequestable: Requestable {
    var encoding: Request.Encoding = .query
    var httpMethod: HTTP.Method = .get
    var endpoint: EndpointType = Endpoint.endpoint
    var authorization: Request.Authorization
    var contentType: String?
}

private enum Endpoint: EndpointType {
    case endpoint
    var path: String { "path" }
}
