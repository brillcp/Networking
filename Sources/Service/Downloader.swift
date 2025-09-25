import Foundation

public extension Network.Service {
    /// A downloader actor that handles file downloads with progress tracking
    actor Downloader {
        // MARK: Private properties
        private let url: URL
        private var downloadTask: URLSessionDownloadTask?
        private var progressContinuation: AsyncStream<Float>.Continuation?

        // MARK: - Public
        public struct DownloadHandle {
            public let progress: AsyncStream<Float>
            public let finished: Task<URL, Error>
            public let cancel: @Sendable () -> Void
        }

        // MARK: - Init
        init(url: URL) {
            self.url = url
        }
    }
}

// MARK: - Public functions
public extension Network.Service.Downloader {
    /// Starts the download for the URL configured in the downloader and returns
    /// a handle for observing progress, awaiting completion, or cancelling.
    ///
    /// - Returns: A `DownloadHandle` containing:
    ///   - `progress`: An `AsyncStream<Float>` emitting values in `0.0...1.0`.
    ///   - `finished`: A `Task<URL, Error>` that resolves with the downloaded file's
    ///     temporary location.
    ///   - `cancel`: A closure that cancels the download and completes the stream.
    func start() -> DownloadHandle {
        let (progressStream, progressCont) = AsyncStream<Float>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        progressContinuation = progressCont
        progressCont.yield(0.0)

        // Kick off the download, expose the completion via a Task
        let finished = Task<URL, Error> {
            try await withCheckedThrowingContinuation { (cc: CheckedContinuation<URL, Error>) in
                let delegate = DownloadDelegate { [weak self] result in
                    Task { [weak self] in
                        await self?.handleCompletion(result, continuation: cc)
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
        }

        return DownloadHandle(
            progress: progressStream,
            finished: finished,
            cancel: { [weak self] in Task { await self?.cancel() } }
        )
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

