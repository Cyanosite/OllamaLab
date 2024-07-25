//
//  ContentView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.interactors) private var interactors: Interactors
    @State private var searchText = ""
    private var filteredConversations: [Conversation] {
        get {
            if searchText.isEmpty {
                appState.conversations
            } else {
                appState.conversations.filter {
                    $0.title.lowercased().contains(searchText.lowercased())
                }
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            SearchView(searchText: $searchText)
                .disabled(appState.conversations.isEmpty)
            List(selection: $appState.selectedConversation) {
                ForEach(filteredConversations) { conversation in
                    if conversation.title.isEmpty {
                        ProgressView()
                            .tag(conversation)
                            .controlSize(.small)
                    } else {
                        Text(conversation.title)
                            .tag(conversation)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            ConversationView()
                .environmentObject(appState)
                .background(.thinMaterial)
        }
        .alert(appState.alertMessage, isPresented: $appState.isAlertShowing) {
            Button("Ok", role: .cancel) {}
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu(appState.modelName) {
                    Button("llama3.1") {
                        setModel(modelName: "llama3.1")
                    }
                    Button("llama3") {
                        setModel(modelName: "llama3")
                    }
                }
            }
        }
    }

    private func setModel(modelName: String) {
        appState.modelName = modelName
    }
}

#Preview {
    let appState = AppState()
    appState.conversations.append(Conversation())
    appState.selectedConversation = appState.conversations.first!
    appState.selectedConversation.messages.append(Message(role: .user, content: "Hi!"))
    appState.selectedConversation.messages.append(Message(role: .assistant, content: "Hey there!"))
    appState.selectedConversation.title = "Example message"
    return ContentView()
        .environmentObject(appState)
}
