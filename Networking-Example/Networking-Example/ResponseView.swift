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
                Text(viewModel.string)
                    .font(.caption2)
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

    init(apiData: APIListData, request: Requestable) {
        self.apiData = apiData
        let server: ServerConfig = .basic(baseURL: apiData.url)
        self.service = Network.Service(server: server)
        self.request = request
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        guard let data = try? await service.data(request) else { return }
        string = String(data: data, encoding: .utf8) ?? "no data"
    }
}
