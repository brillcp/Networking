import SwiftUI
import Networking

struct DownloadView: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.state {
            case .idle:
                Button("Start Download") {
                    viewModel.startDownload()
                }
                .buttonStyle(.borderedProminent)

            case .downloading(let progress):
                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 40)
                    Text("\(Int(progress * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Button("Cancel") {
                        viewModel.cancelDownload()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

            case .completed(let data):
                if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                Text("Download complete")
                    .font(.caption)
                    .foregroundStyle(.green)
                Button("Reset") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)

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
                    viewModel.startDownload()
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Download")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DownloadView(viewModel: DownloadViewModel(apiData: .httpBin))
}

// MARK: - ViewModel

final class DownloadViewModel: ObservableObject {
    enum State {
        case idle
        case downloading(Float)
        case completed(Data)
        case failed(String)
    }

    private let service: Network.Service
    private let url: URL
    private var cancelAction: (@Sendable () -> Void)?

    @Published var state: State = .idle

    init(apiData: APIListData) {
        let server: ServerConfig = .basic(baseURL: apiData.url)
        self.service = Network.Service(server: server)
        self.url = apiData.url.appendingPathComponent("image/jpeg")
    }

    func startDownload() {
        state = .downloading(0)
        let downloader = service.downloader(url: url)

        Task { @MainActor in
            let handle = await downloader.start()
            cancelAction = handle.cancel

            // Track progress
            Task { @MainActor in
                for await progress in handle.progress {
                    self.state = .downloading(progress)
                }
            }

            // Await completion
            do {
                let fileURL = try await handle.finished.value
                let data = try Data(contentsOf: fileURL)
                state = .completed(data)
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

    func cancelDownload() {
        cancelAction?()
    }

    func reset() {
        state = .idle
    }
}
