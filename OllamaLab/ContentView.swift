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
    @Environment(\.modelContext) private var context
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
                            .swipeActions(edge: .trailing) {
                                Button {
                                    context.delete(conversation)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                        .tint(.red)
                                }
                            }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            ConversationView()
                .environmentObject(appState)
        }
        .onAppear {
            Task(priority: .background) {
                await interactors.modelsInteractor.fetchTags()
            }
        }
        .alert(appState.alertMessage, isPresented: $appState.isAlertShowing) {
            Button("Ok", role: .cancel) {}
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu(appState.selectedModel) {
                    ForEach(appState.models, id: \.self) { modelName in
                        Button(modelName) {
                            setModel(modelName: modelName)
                        }
                    }
                }
            }
        }
    }

    private func setModel(modelName: String) {
        appState.selectedModel = modelName
    }
}

#Preview {
    let appState = AppState()
    return ContentView()
        .modelContainer(ConversationContainer.shared)
        .environmentObject(appState)
}
