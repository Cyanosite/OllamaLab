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
                .foregroundColor(.gray)
                .padding(.leading, 5)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hue: 1.0, saturation: 0.03, brightness: 0.344, opacity: 0.466))
                .stroke(.gray)
        }
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
