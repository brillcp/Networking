//
//  DownloadPublisher.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation
import Combine

public extension Network.Service {
    /// A downloader structure object used to track and progress file downloads
    struct Downloader: Publisher {
        public typealias Failure = Error

        // MARK: Private properties
        private let url: URL

        // MARK: - Public properties
        /// The publisher output
        public enum Output {
            /// The destination case containing the temporary file destination
            case destination(URL)
            /// The progress case containing the download progress as a `Float` value
            case progress(Float)
        }

        // MARK: - Init
        /// Initialize the download publisher
        /// - parameter url: The given file URL
        init(url: URL) {
            self.url = url
        }

        // MARK: - Public functions
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
            let subscription = DownloadSubscription(subscriber, url: url)
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: -
private extension Network.Service {

    /// A subscriber object that conforms to `URLSessionDownloadDelegate` used to report and track URL session downloads
    private final class DownloadSubscription<S: Subscriber>: Network.Service.Sub<S>, URLSessionDownloadDelegate where S.Input == Downloader.Output, S.Failure == Error {
        // MARK: Private properties
        private var session: URLSession!
        private let url: URL

        // MARK: - Init
        /// Init the subscriber
        /// - parameters:
        ///     - subscriber: The given subscriber
        ///     - url: The URL to the file to download
        init(_ subscriber: S, url: URL) {
            self.url = url
            super.init(subscriber: subscriber)

            session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
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
