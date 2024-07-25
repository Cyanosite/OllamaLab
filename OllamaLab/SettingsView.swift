//
//  SettingsView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("baseURL") private var baseURL = "http://localhost:11434/api"
    @AppStorage("isHistoryUsed") private var isHistoryUsed = true
    var body: some View {
        Form {
            Toggle("Use history", isOn: $isHistoryUsed)
            TextField("Ollama base URL", text: $baseURL)
        }
    }
}

#Preview {
    SettingsView()
}
