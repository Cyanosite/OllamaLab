//
//  ContentView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.interactors) private var interactors: Interactors
    @State private var searchText = ""
    @Query(
        sort: [SortDescriptor(\Conversation.creationDate, order: .reverse)]
    )
    var conversations: [Conversation]
    private var filteredConversations: [Conversation] {
        get {
            if searchText.isEmpty {
                conversations
            } else {
                conversations.filter({$0.title.contains(searchText)})
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            SearchView(searchText: $searchText)
                .disabled(conversations.isEmpty)
            List(selection: $appState.selectedConversation) {
                ForEach(filteredConversations) { conversation in
                    if conversation.title.isEmpty {
                        ProgressView()
                            .tag(conversation.id as UUID?)
                            .controlSize(.small)
                    } else {
                        Text(conversation.title)
                            .tag(conversation.id as UUID?)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            ConversationView()
                .environmentObject(appState)
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
    return ContentView()
        .modelContainer(ConversationContainer.shared)
        .environmentObject(appState)
}
