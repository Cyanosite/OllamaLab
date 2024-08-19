//
//  SettingView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 19/08/2024.
//

import SwiftUI

struct SettingView<Content: View>: View {
    let systemImage: String
    let setting: String
    @ViewBuilder let ContentView: Content
    var body: some View {
        HStack {
            Label(setting, systemImage: systemImage)
            ContentView
                .foregroundStyle(.gray)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
        }
    }
}

struct SettingViewPreviewWrapper: View {
    @State private var baseURL = "http://localhost:11434"
    var body: some View {
        SettingView(systemImage: "globe", setting: "Ollama base URL") {
            TextField("http://localhost:11434", text: $baseURL)
                .onKeyPress(.tab) {
                    if baseURL.isEmpty {
                        baseURL = "http://localhost:11434"
                    }
                    return .handled
                }
        }
    }
}

#Preview {
    SettingViewPreviewWrapper()
}
