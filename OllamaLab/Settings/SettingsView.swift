//
//  SettingsView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI
import HotKey

struct SettingsView: View {
    @AppStorage("baseURL") private var baseURL = "http://localhost:11434"
    @AppStorage("companionPosition") private var companionPosition: CompanionPosition = .bottomLeft
    @AppStorage("companionResetInterval") private var companionResetInterval: CompanionResetInterval = .afterTenMinutes
    @AppStorage("companionOpenIn") private var companionOpenIn: CompanionOpenNewChats = .inCompanion
    @State private var isHoveringReset = false
    var body: some View {
        ScrollView {
            SettingsSectionView("App") {
                SettingView(systemImage: "globe", setting: "Ollama Base URL") {
                    TextField("http://localhost:11434", text: $baseURL)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.trailing)
                        .onKeyPress(.tab) {
                            if baseURL.isEmpty {
                                baseURL = "http://localhost:11434"
                            }
                            return .handled
                        }
                }
            }
            SettingsSectionView("Companion") {
                SettingView(systemImage: "dock.rectangle", setting: "Position on Screen") {
                    Picker("", selection: $companionPosition) {
                        Text("Bottom Left").tag(CompanionPosition.bottomLeft)
                        Text("Bottom Center").tag(CompanionPosition.bottomCenter)
                        Text("Bottom Right").tag(CompanionPosition.bottomRight)
                        Divider()
                        Text("Remember Last Position").tag(CompanionPosition.rememberLast)
                    }
                    .tint(.gray)
                    .buttonStyle(.borderless)
                }
                SettingView(systemImage: "plus.bubble", setting: "Reset to New Chat") {
                    Picker("", selection: $companionResetInterval) {
                        Text("Immediately").tag(CompanionResetInterval.immediately)
                        Divider()
                        Text("After 10 Minutes").tag(CompanionResetInterval.afterTenMinutes)
                        Text("After 15 Minutes").tag(CompanionResetInterval.afterFifteenMinutes)
                        Text("After 30 Minutes").tag(CompanionResetInterval.afterThirtyMinutes)
                        Divider()
                        Text("Never").tag(CompanionResetInterval.never)
                    }
                    .tint(.gray)
                    .buttonStyle(.borderless)
                }
                SettingView(systemImage: "arrow.up.forward.app", setting: "Open New Chats") {
                    Picker("", selection: $companionOpenIn) {
                        Text("In Companion Chat").tag(CompanionOpenNewChats.inCompanion)
                        Text("In Main Window").tag(CompanionOpenNewChats.inApp)
                    }
                    .tint(.gray)
                    .buttonStyle(.borderless)
                }
            }
        }
        .frame(minWidth: 600, idealWidth: 600, minHeight: 300, idealHeight: 300)
    }
}

enum CompanionPosition: Int, CaseIterable, Identifiable {
    case bottomLeft, bottomCenter, bottomRight, rememberLast
    var id: Self { self }
}

enum CompanionResetInterval: Int, CaseIterable, Identifiable {
    case immediately = 0, afterTenMinutes = 10, afterFifteenMinutes = 15, afterThirtyMinutes = 30, never = 1
    var id: Self { self }
}

enum CompanionOpenNewChats: Int, CaseIterable, Identifiable {
    case inCompanion, inApp
    var id: Self { self }
}

class CompanionShortcut {
    let key: Key
    let modifiers: NSEvent.ModifierFlags

    init(key: Key, modifiers: NSEvent.ModifierFlags) {
        self.key = key
        self.modifiers = modifiers
    }
}

#Preview {
    SettingsView()
}
