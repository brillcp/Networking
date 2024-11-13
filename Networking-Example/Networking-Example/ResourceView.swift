//
//  ResourceView.swift
//  Networking-Example
//
//  Created by VG on 2024-11-13.
//

import SwiftUI
import Networking_Swift

struct ResourceView: View {
    @ObservedObject private var viewModel: ResourceViewModel

    init(apiData: APIListData) {
        self.viewModel = ResourceViewModel(apiData: apiData)
    }

    var body: some View {
        NavigationView {
            List(viewModel.endpoints, id: \.endpoint.path) { request in
                NavigationLink(destination: view(fromRequestable: request)) {
                    Text(request.endpoint.path)
                }
            }
            .navigationTitle(viewModel.apiData.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    func view(fromRequestable request: Requestable) -> some View {
        let view = ResponseView(viewModel: .init(apiData: viewModel.apiData, request: request))
        if let request = request as? HTTPBin.Request {
            switch request {
            case .jpeg, .png:
                let vm = ImageViewModel(apiData: viewModel.apiData, request: request)
                ImageView(viewModel: vm)
            default:
                view
            }
        } else {
            view
        }
    }
}

#Preview {
    ResourceView(apiData: .httpBin)
}

final class ResourceViewModel: ObservableObject {
    let endpoints: [Requestable]
    let apiData: APIListData

    init(apiData: APIListData) {
        self.apiData = apiData
        self.endpoints = apiData.endpoints
    }
}
