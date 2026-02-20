import Foundation

public extension Network.Service {
    /// An uploader actor that handles data uploads with progress tracking
    actor Uploader {
        // MARK: Private properties
        private let request: URLRequest
        private let data: Data
        private var uploadTask: URLSessionUploadTask?
        private var progressContinuation: AsyncStream<Float>.Continuation?

        // MARK: - Public
        public struct UploadHandle: Sendable {
            public let progress: AsyncStream<Float>
            public let finished: Task<Data, Error>
            public let cancel: @Sendable () -> Void
        }

        // MARK: - Init
        init(request: URLRequest, data: Data) {
            self.request = request
            self.data = data
        }
    }
}

// MARK: - Public functions
public extension Network.Service.Uploader {
    /// Starts the upload and returns a handle for observing progress,
    /// awaiting completion, or cancelling.
    ///
    /// - Returns: An `UploadHandle` containing:
    ///   - `progress`: An `AsyncStream<Float>` emitting values in `0.0...1.0`.
    ///   - `finished`: A `Task<Data, Error>` that resolves with the server's response data.
    ///   - `cancel`: A closure that cancels the upload and completes the stream.
    func start() -> UploadHandle {
        let (progressStream, progressCont) = AsyncStream<Float>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        progressContinuation = progressCont
        progressCont.yield(0.0)

        let uploadRequest = request
        let uploadData = data

        let finished = Task<Data, Error> {
            try await withCheckedThrowingContinuation { (cc: CheckedContinuation<Data, Error>) in
                let delegate = UploadDelegate { [weak self] result in
                    Task { [weak self] in
                        await self?.handleCompletion(result, continuation: cc)
                    }
                } progressHandler: { [weak self] progress in
                    Task { [weak self] in
                        await self?.handleProgress(progress)
                    }
                }

                let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
                let task = session.uploadTask(with: uploadRequest, from: uploadData)
                uploadTask = task
                task.resume()
            }
        }

        return UploadHandle(
            progress: progressStream,
            finished: finished,
            cancel: { [weak self] in Task { await self?.cancel() } }
        )
    }

    /// Cancel the ongoing upload
    func cancel() {
        uploadTask?.cancel()
        progressContinuation?.finish()
    }
}

// MARK: - Private functions
private extension Network.Service.Uploader {
    func handleCompletion(_ result: Result<Data, Error>, continuation: CheckedContinuation<Data, Error>) {
        switch result {
        case .success(let data): continuation.resume(returning: data)
        case .failure(let error): continuation.resume(throwing: error)
        }
        progressContinuation?.finish()
    }

    func handleProgress(_ progress: Float) {
        progressContinuation?.yield(progress)
    }
}

// MARK: - Upload Delegate
private final class UploadDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    private let completionHandler: @Sendable (Result<Data, Error>) -> Void
    private let progressHandler: @Sendable (Float) -> Void
    private var receivedData = Data()

    init(completionHandler: @escaping @Sendable (Result<Data, Error>) -> Void, progressHandler: @escaping @Sendable (Float) -> Void) {
        self.completionHandler = completionHandler
        self.progressHandler = progressHandler
        super.init()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        progressHandler(progress)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler(.failure(error))
        } else {
            completionHandler(.success(receivedData))
        }
    }
}
