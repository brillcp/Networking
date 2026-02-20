import SwiftUI
import Networking

struct ImageView: View {
    @ObservedObject var viewModel: ImageViewModel

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .onAppear {
                    Task { await viewModel.load() }
                }
        } else {
            if let data = viewModel.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}

#Preview {
    let vm = ImageViewModel(apiData: .github, request: HTTPBin.Request.jpeg)
    return ImageView(viewModel: vm)
}

final class ImageViewModel: ObservableObject {
    private let service: Network.Service
    private let apiData: APIListData
    private let request: Requestable

    @Published var isLoading: Bool = true
    @Published var imageData: Data?

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
        guard let data = try? await service.data(request) else { return }
        imageData = data
    }
}
