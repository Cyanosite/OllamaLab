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
    let appState: AppState
    let interactors: Interactors
    let hotKeyOpen = HotKey(key: .space, modifiers: .option)
    let hotKeySpotlight = HotKey(key: .space, modifiers: .command)

    init() {
        appState = AppState()
        let conversationInteractor = ConversationInteractor(appState: appState, repository: AIRepository())
        interactors = Interactors(appState: appState, conversationInteractor: conversationInteractor)
        let panelView = PopUpView()
            .environmentObject(appState)
            .environment(\.interactors, interactors)
            .edgesIgnoringSafeArea(.top)
        appState.panel = FloatingPanel(hostingView: NSHostingView(rootView: panelView))

        hotKeyOpen.keyDownHandler = { [self] in
            if appState.panel.occlusionState.contains(.visible) && appState.panel.isVisible {
                appState.panel.orderOut(nil)
            } else {
                NSApp.activate()
                appState.panel!.center()
                appState.panel!.makeKeyAndOrderFront(nil)
            }
        }
        hotKeySpotlight.keyDownHandler = { [self] in
            if appState.panel.occlusionState.contains(.visible) && appState.panel.isVisible {
                appState.panel.orderOut(nil)
            }
        }
    }

    var body: some Scene {
        WindowGroup("ContentView", id: "ContentView") {
            ContentView()
        }
        .environmentObject(appState)
        .environment(\.interactors, interactors)

        Window("PopUpView", id: "PopUpView") {
            PopUpView()
                .environmentObject(appState)
                .environment(\.interactors, interactors)
        }
        Settings {
            SettingsView()
        }
        MenuBarExtra("OllamaLab", systemImage: "star", isInserted: $showMenuBarExtra)
        {
            MenuBarView()
        }
    }
}
