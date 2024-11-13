//
//  Downloader.swift
//  Networking
//
//  Created by Viktor Gidlöf.
//

import Foundation

public extension Network.Service {
    /// A downloader actor that handles file downloads with progress tracking
    actor Downloader {
        // MARK: Private properties
        private let url: URL
        private let session: URLSession
        private var downloadTask: URLSessionDownloadTask?
        private var progressContinuation: AsyncStream<Float>.Continuation?

        // MARK: - Init
        init(url: URL, session: URLSession = .shared) {
            self.url = url
            self.session = session
        }
    }
}

// MARK: - Public functions
public extension Network.Service.Downloader {
    /// Start downloading the file and track progress
    /// - Returns: A tuple containing the downloaded file URL and an AsyncStream of progress updates
    func download() async throws -> (URL, AsyncStream<Float>) {
        let (stream, continuation) = AsyncStream<Float>.makeStream()
        progressContinuation = continuation
        continuation.yield(0.0)

        let downloadedURL = try await withCheckedThrowingContinuation { continuation in
            let delegate = DownloadDelegate { [weak self] result in
                Task { [weak self] in
                    await self?.handleCompletion(result, continuation: continuation)
                }
            } progressHandler: { [weak self] progress in
                Task { [weak self] in
                    await self?.handleProgress(progress)
                }
            }
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
            let task = session.downloadTask(with: url)
            downloadTask = task
            task.resume()
        }
        return (downloadedURL, stream)
    }

    /// Cancel the ongoing download
    func cancel() {
        downloadTask?.cancel()
        progressContinuation?.finish()
    }
}

// MARK: - Private functions
private extension Network.Service.Downloader {
    func handleCompletion(_ result: Result<URL, Error>, continuation: CheckedContinuation<URL, Error>) {
        switch result {
        case .success(let url): continuation.resume(returning: url)
        case .failure(let error): continuation.resume(throwing: error)
        }
        progressContinuation?.finish()
    }
    
    func handleProgress(_ progress: Float) {
        progressContinuation?.yield(progress)
    }
}

// MARK: - Download Delegate
private final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let completionHandler: (Result<URL, Error>) -> Void
    private let progressHandler: (Float) -> Void
    
    init(completionHandler: @escaping (Result<URL, Error>) -> Void, progressHandler: @escaping (Float) -> Void) {
        self.completionHandler = completionHandler
        self.progressHandler = progressHandler
        super.init()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completionHandler(.success(location))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler(.failure(error))
        }
    }
}
