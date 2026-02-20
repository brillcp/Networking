import SwiftUI
import Networking

struct UploadView: View {
    @ObservedObject var viewModel: UploadViewModel

    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.state {
            case .idle:
                Button("Start Upload") {
                    viewModel.startUpload()
                }
                .buttonStyle(.borderedProminent)

            case .uploading(let progress):
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 40)
                    Text("\(Int(progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Button("Cancel") {
                        viewModel.cancelUpload()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

            case .completed(let response):
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upload complete")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                        Divider()
                        Text(response)
                            .font(.caption2)
                    }
                    .padding(.horizontal)
                }
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .padding(.bottom)

            case .failed(let message):
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") {
                    viewModel.startUpload()
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UploadView(viewModel: UploadViewModel(apiData: .httpBin, request: HTTPBin.Request.upload))
}

// MARK: - ViewModel

final class UploadViewModel: ObservableObject {
    enum State {
        case idle
        case uploading(Float)
        case completed(String)
        case failed(String)
    }

    private let service: Network.Service
    private let request: Requestable
    private var cancelAction: (@Sendable () -> Void)?

    @Published var state: State = .idle

    init(apiData: APIListData, request: Requestable) {
        self.request = request

        let server: ServerConfig
        if let tokenProvider = apiData.tokenProvider {
            server = .authenticated(baseURL: apiData.url, tokenProvider: tokenProvider)
        } else {
            server = .basic(baseURL: apiData.url)
        }
        self.service = Network.Service(server: server, interceptors: apiData.interceptors)
    }

    func startUpload() {
        state = .uploading(0)

        Task { @MainActor in
            do {
                let uploader = try await service.uploader(for: request)
                let handle = await uploader.start()
                cancelAction = handle.cancel

                // Track progress
                Task { @MainActor in
                    for await progress in handle.progress {
                        self.state = .uploading(progress)
                    }
                }

                // Await completion
                let data = try await handle.finished.value
                let response = String(data: data, encoding: .utf8) ?? "no data"
                state = .completed(response)
            } catch {
                if (error as NSError).code == NSURLErrorCancelled {
                    state = .idle
                } else {
                    state = .failed(error.localizedDescription)
                }
            }
            cancelAction = nil
        }
    }

    func cancelUpload() {
        cancelAction?()
    }

    func reset() {
        state = .idle
    }
}
