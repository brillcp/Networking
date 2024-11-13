//
//  ContentView.swift
//  Networking-Example
//
//  Created by VG on 2024-11-13.
//

import SwiftUI

struct ContentView: View {
    private let data: [APIListData] = [
        .github, .pokeAPI, .httpBin, .placeholder, .reqres
    ]

    var body: some View {
        NavigationView {
            List(data) { data in
                NavigationLink(destination: ResourceView(apiData: data)) {
                    Text(data.name ?? "")
                }
            }
            .navigationTitle("APIs")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
        }
    }
}

#Preview {
    ContentView()
}
