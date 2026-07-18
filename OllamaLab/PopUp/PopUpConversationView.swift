//
//  PopUpConversationView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 17/08/2024.
//

import SwiftData
import SwiftUI

struct PopUpConversationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) var openWindow
    @Environment(\.interactors) var interactors: Interactors
    @Query private var messages: [Message]
    private var filteredMessages: [Message] {
        get {
            messages.filter { $0.conversation?.id == appState.selectedConversation }.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }
    private var isConversationEmpty: Bool {
        get {
            filteredMessages.isEmpty
        }
    }
    @State private var isHovering = false
    @Namespace private var controlsNamespace

    var body: some View {
        VStack {
            GlassEffectContainer(spacing: 8) {
                HStack {
                    Button {
                        appState.panel.close()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .glassEffectID("close", in: controlsNamespace)
                    Spacer()
                    Button {
                        appState.panel.close()
                        let isMainWindowOpen = {
                            for window in NSApp.orderedWindows where ((window.identifier?.rawValue.contains("ContentView")) != nil) {
                                return true
                            }
                            return false
                        }()
                        if !isMainWindowOpen {
                            openWindow(id: "ContentView")
                        }
                    } label: {
                        Image(systemName: "arrow.up.forward.app")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .glassEffectID("open", in: controlsNamespace)
                    Button {
                        interactors.conversationInteractor.newConversation()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .disabled(isConversationEmpty)
                    .glassEffectID("new", in: controlsNamespace)
                }
            }
            .font(.body)
            .opacity(isHovering ? 1 : 0)
            .onHover { isHovering in
                withAnimation {
                    self.isHovering = isHovering
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            ConversationView(usesGlassComposer: false)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 15))
        .frame(idealWidth: 350, minHeight: 450)
    }
}

struct PopUpConversationViewWrapper: View {
    @State private var didSubmit = false
    var body: some View {
        PopUpConversationView()
    }
}

#Preview {
    let appState = AppState()
    return PopUpConversationViewWrapper()
        .environmentObject(appState)
}
