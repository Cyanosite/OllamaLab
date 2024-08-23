//
//  AppState.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftData

final class AppState: ObservableObject {
    /*static let conversationContainer = ConversationContainer.shared
    @MainActor var conversations: [Conversation] {
        get {
            (try? Self.conversationContainer.mainContext.fetch(FetchDescriptor<Conversation>())) ?? [Conversation]()
        }
    }*/
    @Published var selectedConversation: UUID? {
        didSet {
            print("selectedConversation changed to = \(selectedConversation?.uuidString)")
        }
    }
    @Published var modelName: String = "llama3.1"
    @Published var isModelResponding = false
    @Published var alertMessage = ""
    @Published var isAlertShowing = false
    var panel: FloatingPanel!
}
