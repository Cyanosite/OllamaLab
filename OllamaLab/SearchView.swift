//
//  SearchView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .padding(.leading, 5)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 10))
        .padding(.horizontal, 10)
    }
}

struct MockSearchViewWrapper: View {
    @State private var searchText = ""
    var body: some View {
        SearchView(searchText: $searchText)
    }
}

#Preview {
    MockSearchViewWrapper()
}
