//
//  ConversationInteractor.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftData
import SwiftUI

class ConversationInteractor: ConversationInteractorProtocol {
    let appState: AppState
    let repository: Repository
    let dispatchGroup = DispatchGroup()
    @MainActor var conversations: [Conversation] {
        get {
            do {
                return try ConversationContainer.shared.mainContext.fetch(FetchDescriptor<Conversation>())
            } catch {

            }
            return []
        }
    }
    @MainActor var context = ConversationContainer.shared.mainContext

    init(appState: AppState, repository: Repository) {
        self.appState = appState
        self.repository = repository
    }

    @MainActor func getCurrentConversation() -> Conversation? {
        guard let selectedConversationID = appState.selectedConversation else {
            showErrorMessage()
            return nil
        }
        let fetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate { $0.id == selectedConversationID})
        return try? ConversationContainer.shared.mainContext.fetch(fetchDescriptor).first
    }

    func addNewConversation(conversation: Conversation) {
        DispatchQueue.main.async {
            withAnimation {
                ConversationContainer.shared.mainContext.insert(conversation)
            }
        }
    }

    func newConversation() {
        DispatchQueue.main.async {
            self.appState.selectedConversation = nil
        }
    }

    func updateCurrentConversationTitle(basedOn messages: [Message]) {
        guard messages.count >= 2 else {
            showErrorMessage()
            return
        }
        let prompt = """
        I am a local large language model running inside a chat application and I want to generate a very short title for the user's conversation, I will create a couple word title based on the user's message and the model's response.

        Here is the user message and the model's response, only return the title in a couple of words, do not add comments:
        user message: \(messages[messages.endIndex - 1].content)
        model response/ \(messages[messages.endIndex - 2].content)
        title:
        """
        try? repository.generateCompletion(model: appState.modelName, with: prompt, handler: updateCurrentConversationTitleHandler)
    }

    func updateCurrentConversationTitleHandler(data: Data) {
        let string = String(data: data, encoding: .utf8)!
        print(string)
        if let response = try? CompletionResponse.decoder.decode(CompletionResponse.self, from: data) {
            DispatchQueue.main.sync {
                withAnimation {
                    getCurrentConversation()!.title = response.response.capitalized
                }
            }
        }
    }

    func sendMessage(role: Role, content: String, streaming: Bool) async {
        guard !appState.isModelResponding else {
            showErrorMessage()
            return
        }
        if await !conversations.contains(where: { $0.id == appState.selectedConversation}) {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    let conversation = Conversation()
                    context.insert(conversation)
                    appState.selectedConversation = conversation.id
                }
            }
        }
        guard let selectedConversation = appState.selectedConversation else {
            showErrorMessage()
            return
        }

        DispatchQueue.main.sync {
            guard var selectedConversation = getCurrentConversation() else {
                showErrorMessage()
                return
            }
            let message = Message(conversation: selectedConversation, role: role, content: content)
            if selectedConversation.messages != nil {
                selectedConversation.messages!.append(message)
            } else {
                selectedConversation.messages = [message]
            }
            self.appState.isModelResponding = true
        }
        await sendGenerateResponseRequest(streaming: streaming)
    }

    func sendGenerateResponseRequest(streaming: Bool) async {
        do {
            guard let history = await getCurrentConversation()?.messages?.sorted(by: {$0.timestamp < $1.timestamp}) else {
                showErrorMessage()
                return
            }
            if streaming {
                DispatchQueue.main.sync {
                    MainActor.assumeIsolated {
                        guard let currentConversation = getCurrentConversation() else {
                            return
                        }
                        let message = Message(conversation: currentConversation, role: .assistant)
                        currentConversation.messages?.append(message)
                        Task {
                            try await repository.generateResponseStreaming(model: appState.modelName, with: history, handler: handleSendMessageResponseStreaming, messageID: message.id)
                        }
                    }
                }
            } else {
                try repository.generateResponse(model: appState.modelName, with: history, handler: handleSendMessageResponse)
            }
        } catch {
            DispatchQueue.main.async {
                self.appState.alertMessage = "Ollama is currently unavailable"
                self.appState.isAlertShowing = true
                self.appState.isModelResponding = false
            }
        }
    }

    func handleSendMessageResponse(data: Data) {
        if let response = try? Response.decoder.decode(Response.self, from: data) {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    withAnimation {
                        guard let currentConversation = getCurrentConversation() else {
                            showErrorMessage()
                            return
                        }
                        guard var messages = currentConversation.messages else {
                            showErrorMessage()
                            return
                        }
                        messages.append(Message(conversation: currentConversation, message: response.message))
                    }
                }
            }
        }
        DispatchQueue.main.sync {
            self.appState.isModelResponding = false
        }
    }

    func handleSendMessageResponseStreaming(id: UUID, line: String) async {
        if let jsonData = line.data(using: .utf8), let response = try? Response.decoder.decode(Response.self, from: jsonData) {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    guard let message = try? ConversationContainer.shared.mainContext.fetch(FetchDescriptor<Message>(predicate: #Predicate { $0.id == id })).first else {
                        showErrorMessage()
                        return
                    }
                    message.content += response.message.content
                    if response.done {
                        guard let currentConversation = getCurrentConversation() else {
                            showErrorMessage()
                            return
                        }
                        self.appState.isModelResponding = false
                        if currentConversation.messages!.count == 2 {
                            self.updateCurrentConversationTitle(basedOn: currentConversation.messages!.sorted(by: { $0.timestamp < $1.timestamp}))
                        }
                        for message in currentConversation.messages! {
                            print(message.content)
                        }
                    }
                }
            }
        }
    }

    func regenerateMessage(at selectedMessageIndex: Int, streaming: Bool) async {
        DispatchQueue.main.sync {
            MainActor.assumeIsolated {
                withAnimation {
                    guard let currentConversation = getCurrentConversation() else {
                        showErrorMessage()
                        return
                    }
                    guard getCurrentConversation()?.messages != nil else {
                        showErrorMessage()
                        return
                    }
                    let firstToDeleteTimestamp = currentConversation.messages!.sorted(by: { $0.timestamp < $1.timestamp })[selectedMessageIndex].timestamp
                    currentConversation.messages!.removeAll(where: { firstToDeleteTimestamp <= $0.timestamp})
                    self.appState.isModelResponding = true
                }
            }
        }
        await sendGenerateResponseRequest(streaming: streaming)
    }

    func showErrorMessage() {
        DispatchQueue.main.async {
            self.appState.alertMessage = "An error has occurred"
            self.appState.isAlertShowing = true
            self.appState.isModelResponding = false
        }
    }
}
