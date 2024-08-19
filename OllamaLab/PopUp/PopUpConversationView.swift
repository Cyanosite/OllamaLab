//
//  PopUpConversationView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 17/08/2024.
//

import SwiftUI

struct PopUpConversationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) var openWindow
    @Environment(\.interactors) var interactors: Interactors
    private var didSubmit: Bool {
        get {
            !appState.selectedConversation.messages.isEmpty
        }
    }
    private var isConversationEmpty: Bool {
        get {
            appState.selectedConversation.messages.isEmpty
        }
    }
    @State private var isHovering = false

    var body: some View {
        VStack {
            HStack {
                Button {
                    appState.panel.orderOut(nil)
                } label: {
                    Image(systemName: "x.circle.fill")
                }
                .padding(5)
                Spacer()
                Button {
                    appState.panel.orderOut(nil)
                    let windowCount = NSWindow.windowNumbers()?.count
                    if let windowCount, windowCount <= 2 {
                        openWindow(id: "ContentView")
                    }
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                }
                .padding(5)
                Button {
                    interactors.conversationInteractor.newConversation()
                } label: {
                    Image(systemName: "square.and.pencil.circle")
                }
                .padding(5)
                .disabled(isConversationEmpty)
            }
            .font(.title2)
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovering ? 1 : 0)
            .onHover { isHovering in
                withAnimation {
                    self.isHovering = isHovering
                }
            }
            ConversationView()
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .stroke(.white)
        }
        .padding(1)
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
    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState, repository: AIRepository()))
    return PopUpConversationViewWrapper()
        .environmentObject(appState)
        .environment(\.interactors, interactors)
}
