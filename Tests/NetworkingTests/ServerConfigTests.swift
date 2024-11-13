//
//  ServerConfigTests.swift
//  Networking
//
//  Created by VG on 2024-11-13.
//

import XCTest
@testable import Networking

final class ServerConfigV2Tests: XCTestCase {
    private let validURLString = "https://api.example.com"
    private let tokenProviderMock = MockTokenProvider()
    private var config: ServerConfig!

    override func setUp() {
        super.setUp()
        config = ServerConfig(baseURL: validURLString, tokenProvider: tokenProviderMock)
    }

    override func tearDown() {
        config = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests
    func testInitialization_withValidURL_shouldSucceed() {
        let config = ServerConfig(baseURL: validURLString, userAgent: "TestAgent/1.0")
        XCTAssertEqual(config?.baseURL.absoluteString, validURLString)
        XCTAssertEqual(config?.userAgent, "TestAgent/1.0")
    }

    func testInitialization_withInvalidURL_shouldReturnNil() {
        let config = ServerConfig(baseURL: "") // <-- Invalid URL string
        XCTAssertNil(config)
    }

    // MARK: - Header Generation Tests
    func testHeaderGeneration_includesBaseHeaders() {
        let request = MockRequestable(authorization: .none)
        let headers = config.header(forRequest: request)
        XCTAssertEqual(headers[HTTP.Header.Field.host], config.baseURL.host)
    }
    
    func testHeaderGeneration_includesAdditionalHeaders() {
        let additionalHeaders = ["X-Custom-Header": "CustomValue"]
        let config = ServerConfig(baseURL: validURLString, additionalHeaders: additionalHeaders)
        let headers = config?.header(forRequest: MockRequestable(authorization: .none))
        XCTAssertEqual(headers?["X-Custom-Header"], "CustomValue")
    }

    func testHeaderGeneration_withBearerToken_includesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .success("sampleToken")
        let request = MockRequestable(authorization: .bearer)
        let headers = config.header(forRequest: request)
        XCTAssertEqual(headers[HTTP.Header.Field.auth], "Bearer sampleToken")
    }

    func testHeaderGeneration_withBasicToken_includesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .success("sampleToken")
        let request = MockRequestable(authorization: .basic)
        let headers = config.header(forRequest: request)
        XCTAssertEqual(headers[HTTP.Header.Field.auth], "Basic sampleToken")
    }

    func testHeaderGeneration_withTokenProviderFailure_excludesAuthorizationHeader() {
        tokenProviderMock.tokenResult = .failure(.missing)
        let request = MockRequestable(authorization: .bearer)
        let headers = config.header(forRequest: request)
        XCTAssertNil(headers[HTTP.Header.Field.auth])
    }

    // MARK: - Convenience Initializers Tests
    func testBasicInitializer_createsConfigurationWithDefaultValues() {
        let config = ServerConfig.basic(baseURL: validURLString)
        XCTAssertEqual(config?.baseURL.absoluteString, validURLString)
        XCTAssertNil(config?.tokenProvider)
    }

    func testAuthenticatedInitializer_createsConfigurationWithTokenProvider() {
        let config = ServerConfig.authenticated(baseURL: validURLString, tokenProvider: tokenProviderMock)
        XCTAssertEqual(config?.baseURL.absoluteString, validURLString)
        XCTAssertNotNil(config?.tokenProvider)
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
