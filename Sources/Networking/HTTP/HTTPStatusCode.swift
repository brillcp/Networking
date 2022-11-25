//
//  HTTPStatusCode.swift
//  
//
//  Created by Viktor Gidlöf.
//

import Foundation

public extension HTTP {
    /// An enumeration of the status codes
    enum StatusCode: Int {
        // 100 Informational
        case `continue` = 100
        case switchingProtocols
        case processing
        // 200 Success
        case ok = 200
        case created
        case accepted
        case nonAuthoritativeInformation
        case noContent
        case resetContent
        case partialContent
        case multiStatus
        case alreadyReported
        case iMUsed = 226
        // 300 Redirection
        case multipleChoices = 300
        case movedPermanently
        case found
        case seeOther
        case notModified
        case useProxy
        case switchProxy
        case temporaryRedirect
        case permanentRedirect
        // 400 Client Error
        case badRequest = 400
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case methodNotAllowed
        case notAcceptable
        case proxyAuthenticationRequired
        case requestTimeout
        case conflict
        case gone
        case lengthRequired
        case preconditionFailed
        case payloadTooLarge
        case uriTooLong
        case unsupportedMediaType
        case rangeNotSatisfiable
        case expectationFailed
        case imATeapot
        case misdirectedRequest = 421
        case unprocessableEntity
        case locked
        case failedDependency
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequests
        case requestHeaderFieldsTooLarge = 431
        case unavailableForLegalReasons = 451
        // 500 Server Error
        case internalServerError = 500
        case notImplemented
        case badGateway
        case serviceUnavailable
        case gatewayTimeout
        case httpVersionNotSupported
        case variantAlsoNegotiates
        case insufficientStorage
        case loopDetected
        case notExtended = 510
        case networkAuthenticationRequired
        case unknown = -1
    }
}

// MARK: -
public extension HTTPURLResponse {
    var status: HTTP.StatusCode { HTTP.StatusCode(rawValue: statusCode) ?? .unknown }
}
