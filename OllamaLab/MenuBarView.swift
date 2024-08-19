//
//  MenuBarView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 17/08/2024.
//

import SwiftUI
import HotKey

struct MenuBarView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var appState: AppState
    @State private var message = ""

    var body: some View {
        Button("Open OllamaLab") {
            openWindow(id: "ContentView")
        }
        Button("Open Chat Bar") {
            appState.panel.open()
        }
        .keyboardShortcut(.space, modifiers: .option)
        Divider()
        SettingsLink()
        .keyboardShortcut(",")
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
}

#Preview {
    MenuBarView()
}
