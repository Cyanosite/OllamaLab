//
//  ConversationView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors: Interactors

    @State private var message = ""
    @State private var isMessageEmpty = true
    private var isConversationEmpty: Bool {
        get {
            appState.selectedConversation.messages.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        ForEach(0..<appState.selectedConversation.messages.count, id: \.self) { index in
                            let message = appState.selectedConversation.messages[index]
                            if message.role == .user {
                                UserMessageView(message: message)
                                        .tag(index)
                            } else {
                                AssistantMessageView(message: message, messageIndex: index)
                                        .tag(index)
                            }
                        }
                    }
                    .onChange(of: appState.selectedConversation.messages.last?.content) {
                        value.scrollTo(appState.selectedConversation.messages.endIndex - 1, anchor: .bottom)
                    }
                }
            }
            HStack {
                TextField("Message llama", text: $message)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .padding(.horizontal, 5)
                    .onSubmit {
                        sendMessage()
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke()
                    }
                    .onChange(of: message) {
                        withAnimation(.bouncy) {
                            isMessageEmpty = message.isEmpty
                        }
                    }
                if !appState.isModelResponding && !isMessageEmpty {
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
                Button(action: newConversation) {
                    Label("Add Item", systemImage: "square.and.pencil")
                }
                .disabled(isConversationEmpty)
            }
        }
        .background(.ultraThinMaterial)
    }

    func sendMessage() {
        guard !appState.isModelResponding && !isMessageEmpty else { return }
        if !appState.conversations.contains(appState.selectedConversation) {
            interactors.conversationInteractor.addNewConversation(conversation: appState.selectedConversation)
        }
        let messageToSend = message
        message = ""
        Task(priority: .userInitiated) {
            await interactors.conversationInteractor.sendMessage(message: Message(role: .user, content: messageToSend), streaming: true)
        }
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
    appState.selectedConversation.messages.append(Message(role: .user, content: "Hi!"))
    appState.selectedConversation.messages.append(Message(role: .assistant, content: "Hi, how can I help you today?"))
    appState.selectedConversation.messages.append(Message(role: .user, content: "What's the weather like today?"))
    appState.selectedConversation.messages.append(Message(role: .assistant, content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sed nunc eros. Nullam id tincidunt nulla. Quisque nec ante vitae arcu placerat blandit. Nam hendrerit, metus feugiat congue facilisis, nulla nisl luctus massa, vitae molestie quam purus sit amet nulla. Donec elit elit, elementum sed justo fringilla, tempor ornare magna. Fusce vel porta ipsum, at varius nibh. Nullam neque diam, rutrum at tempor eu, efficitur vitae elit. Etiam congue pellentesque tellus non aliquet. Curabitur eget lacus sollicitudin, tristique tellus eget, tincidunt nunc. Maecenas non bibendum metus. Maecenas molestie, nisi in tincidunt laoreet, ipsum nisl semper tellus, id lobortis neque urna ut lectus. Etiam porta ante sit amet tempor eleifend. Vivamus turpis quam, finibus ac velit ac, iaculis tristique enim. Fusce ac velit id mi finibus pharetra. Vestibulum venenatis malesuada urna, et aliquam eros."))

    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState, repository: AIRepository()))
    return ConversationView()
        .environmentObject(appState)
        .environment(\.interactors, interactors)
}
