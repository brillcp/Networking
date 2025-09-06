import SwiftUI
import Networking

struct ResourceView: View {
    private let viewModel: ResourceViewModel

    init(apiData: APIListData) {
        viewModel = ResourceViewModel(apiData: apiData)
    }

    var body: some View {
        List(viewModel.endpoints, id: \.endpoint.path) { request in
            NavigationLink(destination: view(fromRequestable: request)) {
                Text(request.endpoint.path)
                    .font(.caption)
            }
        }
        .navigationTitle(viewModel.apiData.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
    }
}

// MARK: - Private
private extension ResourceView {
    @ViewBuilder
    func view(fromRequestable request: Requestable) -> some View {
        if let request = request as? HTTPBin.Request {
            switch request {
            case .jpeg, .png:
                let vm = ImageViewModel(apiData: viewModel.apiData, request: request)
                ImageView(viewModel: vm)
            default:
                ResponseView(viewModel: .init(apiData: viewModel.apiData, request: request))
            }
        } else {
            ResponseView(viewModel: .init(apiData: viewModel.apiData, request: request))
        }
    }
}

#Preview {
    ResourceView(apiData: .httpBin)
}

final class ResourceViewModel {
    let endpoints: [Requestable]
    let apiData: APIListData

    init(apiData: APIListData) {
        self.apiData = apiData
        self.endpoints = apiData.endpoints
    }
}
