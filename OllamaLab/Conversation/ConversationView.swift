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

    /// When false, the composer skips Liquid Glass so it can sit inside a parent glass surface.
    var usesGlassComposer: Bool = true

    @State private var message = ""
    @State private var isMessageEmpty = true
    @Namespace private var composerNamespace
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
            .scrollEdgeEffectStyle(.soft, for: .top)
            composer
                .padding(10)
        }
        .frame(minWidth: 300, minHeight: 100)
        .toolbar {
            ToolbarItem {
                Button(action: openPopUp) {
                    Label("Open PopUp", systemImage: "arrow.up.forward.app")
                }
            }
            ToolbarSpacer(.fixed)
            ToolbarItem {
                Button(action: newConversation) {
                    Label("Add Item", systemImage: "square.and.pencil")
                }
                .disabled(isConversationEmpty)
            }
        }
    }

    @ViewBuilder
    private var composer: some View {
        if usesGlassComposer {
            GlassEffectContainer(spacing: 12) {
                composerControls(useGlass: true)
            }
        } else {
            composerControls(useGlass: false)
        }
    }

    @ViewBuilder
    private func composerControls(useGlass: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message OllamaLab", text: $message, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(7)
                .font(.system(size: 14))
                .fontWeight(.regular)
                .padding(10)
                .padding(.horizontal, 4)
                .modifier(ComposerFieldChrome(useGlass: useGlass))
                .modifier(OptionalGlassEffectID(id: "composer", namespace: composerNamespace, isEnabled: useGlass))
                .onChange(of: message) {
                    withAnimation(.bouncy) {
                        isMessageEmpty = message.isEmpty
                    }
                }
                .onSubmit {
                    sendMessage()
                }
            if !isMessageEmpty && !appState.isModelResponding {
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .modifier(OptionalGlassEffectID(id: "send", namespace: composerNamespace, isEnabled: useGlass))
                .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
                .padding(.bottom, 2)
            }
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

private struct ComposerFieldChrome: ViewModifier {
    let useGlass: Bool

    func body(content: Content) -> some View {
        if useGlass {
            content.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
        } else {
            content.background {
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(.secondary.opacity(0.35))
            }
        }
    }
}

private struct OptionalGlassEffectID: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    let isEnabled: Bool

    func body(content: Content) -> some View {
        if isEnabled {
            content.glassEffectID(id, in: namespace)
        } else {
            content
        }
    }
}

#Preview {
    let appState = AppState()
    return ConversationView()
        .modelContainer(ConversationContainer.shared)
        .environmentObject(appState)
}
