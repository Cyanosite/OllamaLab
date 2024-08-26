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
            HStack(alignment: .bottom, spacing: 0) {
                TextEditor(text: $message)
                    .textEditorStyle(.plain)
                    .font(.system(size: 14))
                    .fontWeight(.regular)
                    .lineLimit(10)
                    .padding(8)
                    .padding(.horizontal, 5)
                    .background {
                        ZStack {
                            HStack {
                                if message.isEmpty {
                                    Text("Message OllamaLab")
                                        .foregroundStyle(.gray)
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .padding(8)
                                        .padding(.horizontal, 10)
                                }
                                Spacer()
                            }
                            RoundedRectangle(cornerRadius: 25)
                                .stroke()
                        }
                    }
                    .frame(minHeight: 25, maxHeight: 200)
                    .fixedSize(horizontal: false, vertical: true)
                    .onAppear(perform: addKeyboardEventListener)
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
                    .padding(4)
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

    func addKeyboardEventListener() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let key = Int(event.keyCode)
            if (key == 0x24 || key == 0x4C) && !event.modifierFlags.contains(.shift) {
                sendMessage()
                return nil
            }
            return event
        }
    }

    func sendMessage() {
        guard !isMessageEmpty && !appState.isModelResponding else { return }
        let messageToSend = message
        withAnimation {
            message = ""
        }
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
