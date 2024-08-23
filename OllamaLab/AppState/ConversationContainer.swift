//
//  ModelContainer.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 22/08/2024.
//

import SwiftData

final class ConversationContainer {
    #if DEBUG
    @MainActor static let shared: ModelContainer = {
        let schema = Schema([
            Conversation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
//            let conversation = Conversation()
//            conversation.title = "Hello chat"
//            let userMessage = Message(conversation: conversation, role: .user, content: "Hi")
//            let assistantMessage = Message(conversation: conversation, role: .assistant, content: "Hi, how can I help you today?")
//            container.mainContext.insert(Conversation())
//            try! container.mainContext.fetch(FetchDescriptor<Conversation>()).first!.messages = [userMessage, assistantMessage]
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    #else
    static let shared: ModelContainer = {
        let schema = Schema([
            Conversation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    #endif
}
