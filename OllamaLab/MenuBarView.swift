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
    @State private var message = ""

    var body: some View {
        Button("Open Chat Bar") {
            openWindow(id: "PopUpView")
        }
        .keyboardShortcut(.space, modifiers: .option)
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
}

#Preview {
    MenuBarView()
}
