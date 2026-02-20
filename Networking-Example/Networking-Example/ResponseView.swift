import SwiftUI
import Networking

struct ResponseView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .onAppear {
                    Task { await viewModel.load() }
                }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Status code
                    HStack {
                        Text("Status")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("\(viewModel.statusCode)")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(viewModel.statusColor.opacity(0.15))
                            .foregroundStyle(viewModel.statusColor)
                            .clipShape(Capsule())
                        Spacer()
                    }

                    // Headers
                    if !viewModel.headers.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Response Headers")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ForEach(viewModel.headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key): \(value)")
                                    .font(.caption2)
                                    .foregroundStyle(.primary.opacity(0.7))
                            }
                        }
                    }

                    Divider()

                    // Body
                    Text(viewModel.string)
                        .font(.caption2)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    let vm = ResponseViewModel(apiData: .github, request: GitHub.GetRequest.user("brillcp"))
    return ResponseView(viewModel: vm)
}

final class ResponseViewModel: ObservableObject {
    private let service: Network.Service
    private let apiData: APIListData
    private let request: Requestable

    @Published var isLoading: Bool = true
    @Published var string: String = ""
    @Published var statusCode: Int = 0
    @Published var headers: [String: String] = [:]

    var statusColor: Color {
        switch statusCode {
        case 200...299: return .green
        case 400...499: return .orange
        case 500...599: return .red
        default: return .gray
        }
    }

    init(apiData: APIListData, request: Requestable) {
        self.apiData = apiData
        self.request = request

        let server: ServerConfig
        if let tokenProvider = apiData.tokenProvider {
            server = .authenticated(baseURL: apiData.url, tokenProvider: tokenProvider)
        } else {
            server = .basic(baseURL: apiData.url)
        }
        self.service = Network.Service(server: server, interceptors: apiData.interceptors)
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response: HTTP.Response<Data> = try await service.send(request)
            statusCode = response.statusCode.rawValue
            headers = response.headers
            string = String(data: response.body, encoding: .utf8) ?? "no data"
        } catch {
            string = error.localizedDescription
        }
    }
}
