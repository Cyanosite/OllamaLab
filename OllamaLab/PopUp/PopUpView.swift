//
//  PopUpView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 17/08/2024.
//

import AppKit
import SwiftData
import SwiftUI

struct PopUpView: View {
    @AppStorage("companionResetInterval") private var companionResetInterval: CompanionResetInterval = .afterTenMinutes
    @AppStorage("companionOpenIn") private var companionOpenIn: CompanionOpenNewChats = .inCompanion
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.interactors) var interactors: Interactors
    @State private var shouldEmptyConversation = false
    @State private var message = ""
    private var didSubmit: Bool {
        get {
            let conversations = try? ConversationContainer.shared.mainContext.fetch(FetchDescriptor<Conversation>())
            guard let messages = conversations?.first(where: { $0.id == appState.selectedConversation})?.messages else {
                return false
            }
            return !messages.isEmpty
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
                    Task {
                        guard companionResetInterval != .never else { return }
                        let minutes = switch(companionResetInterval) {
                            case .immediately:
                                0
                            case .afterTenMinutes:
                                10
                            case .afterFifteenMinutes:
                                15
                            case .afterThirtyMinutes:
                                30
                            case .never:
                                0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(minutes * 60))  {
                            appState.panel.shouldEmptyConversation = true
                        }
                    }
                    let messageToSend = message
                    message = ""
                    Task(priority: .userInitiated) {
                        await interactors.conversationInteractor.sendMessage(role: .user, content: messageToSend, streaming: true)
                    }
                    if companionOpenIn == .inApp {
                        appState.panel.close()
                        openWindow(id: "ContentView")
                    }
                }
                .onAppear {
                    appState.panel?.reposition()
                    appState.panel?.hidesOnDeactivate = true
                }
        } else {
            PopUpConversationView()
                .modelContainer(ConversationContainer.shared)
                .onAppear {
                    appState.panel.repositionChat()
                    appState.panel.hidesOnDeactivate = false
                }
        }
    }
}



class FloatingPanel: NSPanel {
    @AppStorage("companionPosition") private var companionPosition: CompanionPosition = .bottomLeft
    var shouldEmptyConversation = false
    var contentViewWidth: CGFloat!

    init(hostingView: NSHostingView<some View>)
    {
        super.init(contentRect: hostingView.bounds, styleMask: [.nonactivatingPanel, .resizable, .closable, .fullSizeContentView, .utilityWindow, .borderless], backing: .buffered, defer: false)
        self.contentView = hostingView
        self.contentViewWidth = hostingView.bounds.width
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
        reposition()
    }

    // `canBecomeKey` and `canBecomeMain` are required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

    func open() {
        NSApp.activate()
        makeKeyAndOrderFront(nil)
    }

    func reposition() {
        let width = NSScreen.main?.frame.width
        let height = NSScreen.main?.frame.height
        guard companionPosition != .rememberLast, let width, let height else {
            center()
            return
        }
        let relocationHeight = height / 5
        let relocationWidth = switch(companionPosition) {
            case .bottomLeft:
                width / 8
            case .bottomCenter:
                width / 2 - contentViewWidth / 2
            case .bottomRight:
                width - (width / 8) - contentViewWidth
            case .rememberLast:
                CGFloat(0)
        }
        setFrameTopLeftPoint(NSPoint(x: relocationWidth, y: relocationHeight))
    }

    func repositionChat() {
        guard let height = NSScreen.main?.frame.height else { return }
        print(frame.maxY)
        print(height / 5)
        if frame.maxY == (height / 5).rounded(.down) {
            setFrameTopLeftPoint(NSPoint(x: frame.minX, y: frame.minY + 450))
        }
    }
}

#Preview {
    let appState = AppState()
    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState, repository: AIRepository()))
    return PopUpView()
        .environmentObject(appState)
        .environment(\.interactors, interactors)
}


