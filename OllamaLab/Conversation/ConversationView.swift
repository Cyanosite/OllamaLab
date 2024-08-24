//
//  ConversationView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftData
import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var context
    @Environment(\.interactors) var interactors: Interactors

    @State private var message = ""
    @State private var isMessageEmpty = true
    @Query private var messages: [Message]
    private var filteredMessages: [Message] {
        get {
            messages.filter({$0.conversation?.id == appState.selectedConversation}).sorted(by: {$0.timestamp < $1.timestamp})
        }
    }
    private var isConversationEmpty: Bool {
        get {
            return filteredMessages.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        ForEach(0..<filteredMessages.count, id: \.self) { index in
                            let message = filteredMessages[index]
                            if message.role == .user {
                                UserMessageView(message: message)
                                        .tag(index)
                            } else {
                                AssistantMessageView(message: message, messageIndex: index)
                                        .tag(index)
                            }
                        }
                    }
                    .onChange(of: filteredMessages.last?.content) {
                        value.scrollTo(filteredMessages.endIndex - 1, anchor: .bottom)
                    }
                }
            }
            HStack {
                TextField("Message llama", text: $message)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .padding(.horizontal, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke()
                    }
                    .onSubmit {
                        sendMessage()
                    }
                    .onChange(of: message) {
                        withAnimation(.bouncy) {
                            isMessageEmpty = message.isEmpty
                        }
                    }
                if !isMessageEmpty && !appState.isModelResponding {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(SendMessageButtonStyle())
                    .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
                }
            }
            .padding(10)
        }
        .frame(minWidth: 300, minHeight: 100)
        .toolbar {
            ToolbarItem {
                Button(action: openPopUp) {
                    Label("Open PopUp", systemImage: "arrow.up.forward.app")
                }
            }
            ToolbarItem {
                Button(action: newConversation) {
                    Label("Add Item", systemImage: "square.and.pencil")
                }
                .disabled(isConversationEmpty)
            }
        }
    }

    func sendMessage() {
        guard !isMessageEmpty && !appState.isModelResponding else { return }
        let messageToSend = message
        message = ""
        Task(priority: .userInitiated) {
            await interactors.conversationInteractor.sendMessage(role: .user, content: messageToSend, streaming: true)
        }
    }

    func openPopUp() {
        appState.panel.open()
    }

    func newConversation() {
        interactors.conversationInteractor.newConversation()
    }
}

struct SendMessageButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    let appState = AppState()
    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState))
    return ConversationView()
        .modelContainer(ConversationContainer.shared)
        .environmentObject(appState)
        .environment(\.interactors, interactors)
}
