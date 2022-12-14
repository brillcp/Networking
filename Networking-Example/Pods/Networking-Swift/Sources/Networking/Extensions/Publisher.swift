//
//  Publisher.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Combine

public extension Publisher {
    /// Sink the given publisher to a result object with the output and failure values
    /// - parameter result: A completion block that is run when the sink completes or fails, returning a result object
    /// - returns: An `AnyCancellable` that can be erased to any publisher down the pipeline
    func sink(to result: @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable {
        sink { completion in
            switch completion {
            case .failure(let error): result(.failure(error))
            case .finished: break
            }
        } receiveValue: { value in
            result(.success(value))
        }
    }
}
