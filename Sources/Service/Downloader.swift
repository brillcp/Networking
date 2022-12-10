//
//  Downloader.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Combine

public extension Network.Service {

    struct Downloader: Publisher {
        public typealias Output = Response
        public typealias Failure = Error
        
        // MARK: Private properties
        private let url: URL
        
        // MARK: - Public properties
        public enum Response {
            case destination(URL)
            case progress(Float)
        }

        // MARK: - Init
        init(url: URL) {
            self.url = url
        }

        // MARK: - Public functions
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            let subscription = DownloadSub(subscriber, url: url)
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: -
private extension Network.Service {

    private final class DownloadSub<S: Subscriber>: Network.Service.Sub<S>, URLSessionDownloadDelegate where S.Input == Downloader.Response, S.Failure == Error {
        // MARK: Private properties
        private var session: URLSession!
        private let url: URL

        // MARK: - Init
        init(_ subscriber: S, url: URL) {
            self.url = url
            super.init(subscriber: subscriber)

            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
            session.downloadTask(with: url).resume()
            _ = subscriber.receive(.progress(0.0))
        }

        // MARK: - URLSessionDownloadDelegate
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            _ = subscriber?.receive(.progress(progress))
        }

        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            _ = subscriber?.receive(.destination(location))
            subscriber?.receive(completion: .finished)
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let error = error else { return }
            subscriber?.receive(completion: .failure(error))
        }
    }
}

// MARK: -
private extension Network.Service {
    /// A custom subscriber object used for creating subscriptions
    class Sub<S: Subscriber>: NSObject, Subscription {
        // MARK: Private properties
        private(set) var subscriber: S?

        // MARK: - Init
        init(subscriber: S) {
            self.subscriber = subscriber
            super.init()
        }

        // MARK: - Public functions
        func request(_ demand: Subscribers.Demand) {}
        func cancel() { subscriber = nil }
    }
}
