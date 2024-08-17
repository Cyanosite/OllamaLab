//
//  PopUpView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 17/08/2024.
//

import SwiftUI
import AppKit

struct PopUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.interactors) var interactors: Interactors
    @State private var message = ""
    private var didSubmit: Bool {
        get {
            !appState.selectedConversation.messages.isEmpty
        }
    }

    var body: some View {
        if didSubmit == false {
            TextField("Message llama", text: $message)
                .textFieldStyle(.plain)
                .padding(8)
                .padding(.horizontal, 5)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .stroke(.white)
                }
                .padding(1)
                .frame(width: 300)
                .onSubmit {
                    guard !message.isEmpty else { return }
                    let messageToSend = message
                    message = ""
                    Task(priority: .userInitiated) {
                        await interactors.conversationInteractor.sendMessage(message: Message(role: .user, content: messageToSend), streaming: true)
                    }
                }
        } else {
            PopUpConversationView()
                .onAppear {
                    appState.panel.hidesOnDeactivate = false
                }
        }
    }
}



class FloatingPanel: NSPanel {
    @EnvironmentObject var appState: AppState

    init(hostingView: NSHostingView<some View>)
    {
        super.init(contentRect: hostingView.bounds, styleMask: [.nonactivatingPanel, .resizable, .closable, .fullSizeContentView, .utilityWindow, .borderless], backing: .buffered, defer: false)
        self.contentView = hostingView
        self.backgroundColor = .clear

        // Allow the pannel to be on top of almost all other windows
        self.isFloatingPanel = true
        self.level = .floating

        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]

        // Hide title
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        // Since there is no titlebar make the window moveable by click-dragging on the background
        self.isMovableByWindowBackground = true

        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false

        // Activate this if you want the window to hide once it is no longer focused
        self.hidesOnDeactivate = true

        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
    }

    // `canBecomeKey` and `canBecomeMain` are required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
}

#Preview {
    let appState = AppState()
    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState, repository: AIRepository()))
    return PopUpView()
        .environmentObject(appState)
        .environment(\.interactors, interactors)
}


