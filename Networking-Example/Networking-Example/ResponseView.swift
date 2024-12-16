//
//  ResponseView.swift
//  Networking-Example
//
//  Created by VG on 2024-11-13.
//

import SwiftUI
import Networking_Swift

struct ResponseView: View {
    @ObservedObject var viewModel: ResponseViewModel

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .onAppear {
                    Task { await viewModel.load() }
                }
        } else {
            TextEditor(text: $viewModel.string)
                .font(.custom("Menlo", size: 12.0))
                .padding(.horizontal)
                .overlay(Color.clear)
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

    @MainActor func load() async {
        isLoading = true
        guard let data = try? await service.data(request) else { return }
        string = String(data: data, encoding: .utf8) ?? "no data"
        isLoading = false
    }
}
