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
    let repository: ConversationRepositoryProtocol
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

    init(appState: AppState) {
        self.appState = appState
        self.repository = ConversationRepository(appState: appState)
    }

    @MainActor func getCurrentConversation() -> Conversation? {
        guard let selectedConversationID = appState.selectedConversation else {
            showErrorMessage()
            return nil
        }
        let fetchDescriptor = FetchDescriptor<Conversation>(predicate: #Predicate { $0.id == selectedConversationID})
        return try? ConversationContainer.shared.mainContext.fetch(fetchDescriptor).first
    }

    @MainActor
    func addNewConversation() async {
        withAnimation {
            let conversation = Conversation()
            context.insert(conversation)
            appState.selectedConversation = conversation.id
        }
    }

    @MainActor
    func newConversation() {
        self.appState.selectedConversation = nil
    }

    func updateCurrentConversationTitle(basedOn messages: [Message]) async {
        guard messages.count >= 2 else {
            await showErrorMessage(message: "Conversation should already contain at least 2 messages, invalid state")
            return
        }
        let prompt = """
        I am a local large language model running inside a chat application and I want to generate a very short title for the user's conversation, I will create a couple word title based on the user's message and the model's response.

        Here is the user message and the model's response, only return the title in a couple of words, do not add comments:
        user message: \(messages[messages.endIndex - 1].content)
        model response/ \(messages[messages.endIndex - 2].content)
        title:
        """
        try? repository.generateCompletion(model: appState.selectedModel, with: prompt, handler: updateCurrentConversationTitleHandler)
    }

    func updateCurrentConversationTitleHandler(data: Data) async {
        if let title = try? CompletionResponse.decoder.decode(CompletionResponse.self, from: data).response.capitalized {
            await changeCurrentConversationTitle(to: title)
        }
    }

    @MainActor
    func changeCurrentConversationTitle(to title: String) async {
        guard let currentConversation = getCurrentConversation() else {
            showErrorMessage()
            return
        }
        withAnimation {
            currentConversation.title = title
        }
    }

    func sendMessage(role: Role, content: String, streaming: Bool) async {
        if await !conversations.contains(where: { $0.id == appState.selectedConversation }) {
            await addNewConversation()
        }

        await MainActor.run {
            self.appState.isModelResponding = true
        }
        let _ = await addMessageToSelectedConversation(role: role, content: content)
        await sendGenerateResponseRequest(streaming: streaming)
    }

    /// This returns the id of the created message used in sendGenerateResponseRequest
    /// where we need to pass the ID of the message to be modified by the streaming response.
    @MainActor
    func addMessageToSelectedConversation(role: Role, content: String) async -> UUID? {
        guard let selectedConversation = getCurrentConversation() else {
            showErrorMessage()
            return nil
        }
        let message = Message(conversation: selectedConversation, role: role, content: content)
        withAnimation {
            if selectedConversation.messages != nil {
                selectedConversation.messages!.append(message)
            } else {
                selectedConversation.messages = [message]
            }
        }
        return message.id
    }

    @MainActor
    func deleteLastMessageFromSelectedConversation(id: UUID) async {
        guard let selectedConversation = getCurrentConversation() else {
            showErrorMessage()
            return
        }
        if selectedConversation.messages?.count == 2 {
            context.delete(selectedConversation)
        } else {
            withAnimation {
                selectedConversation.messages?.removeAll(where: {$0.id == id})
            }
        }
    }

    func sendGenerateResponseRequest(streaming: Bool) async {
        guard let history = await getCurrentConversation()?.messages?.sorted(by: {$0.timestamp < $1.timestamp}) else {
            await showErrorMessage(message: "Conversation should already contain messages, invalid state")
            return
        }
        guard let messageID = await addMessageToSelectedConversation(role: .assistant, content: "") else {
            await showErrorMessage()
            return
        }
        do {
            if streaming {
                try await repository.generateResponseStreaming(model: appState.selectedModel, with: history, handler: handleSendMessageResponseStreaming, messageID: messageID)
            } else {
                try repository.generateResponse(model: appState.selectedModel, with: history, handler: handleSendMessageResponse)
            }
        } catch {
            await showErrorMessage(message: "Ollama is currently unavailable")
            await deleteLastMessageFromSelectedConversation(id: messageID)
        }
    }

    func handleSendMessageResponse(data: Data) async {
        if let message = try? Response.decoder.decode(Response.self, from: data).message {
            let _ = await addMessageToSelectedConversation(role: message.role, content: message.content)
        } else {
            await showErrorMessage(message: "Unable to decode assistant response.")
        }
        await MainActor.run {
            self.appState.isModelResponding = false
        }
    }

    func handleSendMessageResponseStreaming(id: UUID, line: String) async {
        if let jsonData = line.data(using: .utf8), let response = try? Response.decoder.decode(Response.self, from: jsonData) {
            await updateMessageContent(id: id, with: response)
        } else {
            await showErrorMessage(message: "Error while fetching assistant response")
        }
    }

    @MainActor
    func updateMessageContent(id: UUID, with response: Response) async {
        guard let message = try? context.fetch(FetchDescriptor<Message>(predicate: #Predicate { $0.id == id })).first else {
            showErrorMessage(message: "Message could not be fetched.")
            return
        }
        message.content += response.message.content
        if response.done {
            guard let currentConversation = getCurrentConversation() else {
                showErrorMessage(message: "No conversation selected on action requiring a selected conversation")
                return
            }
            self.appState.isModelResponding = false
            if currentConversation.messages!.count == 2 {
                let history = currentConversation.messages!.sorted(by: { $0.timestamp < $1.timestamp})
                await self.updateCurrentConversationTitle(basedOn: history)
            }
        }
    }

    func regenerateMessage(at selectedMessageIndex: Int, streaming: Bool) async {
        await deleteMessagesStarting(at: selectedMessageIndex)
        await sendGenerateResponseRequest(streaming: streaming)
    }

    @MainActor
    func deleteMessagesStarting(at messageIndex: Int) async {
        withAnimation {
            guard let currentConversation = getCurrentConversation() else {
                showErrorMessage(message: "Trying to regenerate messages without a conversation selected, impossible state.")
                return
            }
            guard currentConversation.messages != nil else {
                showErrorMessage(message: "Trying to regenerate message on conversation with no messages, impossible state.")
                return
            }
            let sortedMessages = currentConversation.messages!.sorted(by: { $0.timestamp < $1.timestamp })
            let firstToDeleteTimestamp = sortedMessages[messageIndex].timestamp
            currentConversation.messages!.removeAll(where: { firstToDeleteTimestamp <= $0.timestamp})
            self.appState.isModelResponding = true
        }
    }

    @MainActor
    func showErrorMessage(message: String = "") {
        withAnimation {
            self.appState.alertMessage = message.isEmpty ? "An error has occurred" : message
            self.appState.isAlertShowing = true
            self.appState.isModelResponding = false
        }
    }
}
