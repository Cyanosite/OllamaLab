//
//  OllamaLabApp.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI
import HotKey

@main
struct OllamaLabApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    let appState = AppState()
    let interactors: Interactors
    let hotKeyOpen = HotKey(key: .space, modifiers: .option)
    let hotKeySpotlight = HotKey(key: .space, modifiers: .command)

    init() {
        let conversationInteractor = ConversationInteractor(appState: appState)
        interactors = Interactors(appState: appState, conversationInteractor: conversationInteractor)
        let panelView = PopUpView()
            .modelContainer(ConversationContainer.shared)
            .environmentObject(appState)
            .environment(\.interactors, interactors)
        appState.panel = FloatingPanel(hostingView: NSHostingView(rootView: panelView))

        hotKeyOpen.keyDownHandler = { [self] in
            if appState.panel.occlusionState.contains(.visible) && appState.panel.isVisible {
                appState.panel.close()
            } else {
                if appState.panel.shouldEmptyConversation {
                    interactors.conversationInteractor.newConversation()
                    appState.panel.shouldEmptyConversation = false
                }
                appState.panel.open()
            }
        }
        hotKeySpotlight.keyDownHandler = { [self] in
            if appState.panel.occlusionState.contains(.visible) && appState.panel.isVisible {
                appState.panel.close()
            }
        }
    }

    var body: some Scene {
        WindowGroup("ContentView", id: "ContentView") {
            ContentView()
        }
        .modelContainer(ConversationContainer.shared)
        .environmentObject(appState)
        .environment(\.interactors, interactors)

        Window("PopUpView", id: "PopUpView") {
            PopUpView()
                .modelContainer(ConversationContainer.shared)
                .environmentObject(appState)
                .environment(\.interactors, interactors)
        }
        Settings {
            SettingsView()
        }
        MenuBarExtra("OllamaLab", systemImage: "star", isInserted: $showMenuBarExtra)
        {
            MenuBarView()
                .environmentObject(appState)
        }
    }
}
