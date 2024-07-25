//
//  OllamaLabApp.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI

@main
struct OllamaLabApp: App {
    let appState: AppState
    let interactors: Interactors

    init() {
        appState = AppState()
        let conversationInteractor = ConversationInteractor(appState: appState, repository: AIRepository())
        interactors = Interactors(appState: appState, conversationInteractor: conversationInteractor)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(appState)
        .environment(\.interactors, interactors)
        Settings {
            SettingsView()
        }
    }
}
