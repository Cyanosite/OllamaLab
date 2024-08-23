//
//  ModelContainer.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 22/08/2024.
//

import SwiftData

final class ConversationContainer {
    @MainActor static let shared: ModelContainer = {
        let schema = Schema([
            Conversation.self,
        ])
#if DEBUG
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
#else
        let modelConfiguration = ModelConfiguration(schema: schema)
#endif
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
