//
//  ConversationInteractor.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

class ConversationInteractor: ConversationInteractorProtocol {
    let appState: AppState
    let repository: Repository
    let dispatchGroup = DispatchGroup()

    init(appState: AppState, repository: Repository) {
        self.appState = appState
        self.repository = repository
    }

    func addNewConversation(conversation: Conversation) {
        DispatchQueue.main.async {
            withAnimation {
                self.appState.conversations.insert(conversation, at: 0)
            }
        }
    }

    func newConversation() {
        DispatchQueue.main.async {
            withAnimation {
                self.appState.selectedConversation = Conversation()
            }
        }
    }

    func updateSelectedConversation(conversation: Conversation) {
        DispatchQueue.main.async {
            withAnimation {
                self.appState.selectedConversation = conversation
            }
        }
    }

    func updateCurrentConversationTitle(basedOn messages: [Message]) {
        guard messages.first != nil, messages.last != nil else { return }
        let prompt = """
        I am a local large language model running inside a chat application and I want to generate a very short title for the user's conversation, I will create a couple word title based on the user's message and the model's response.

        Here is the user message and the model's response, only return the title in a couple of words, do not add comments:
        user message: \(messages.first!)
        model response/ \(messages.last!)
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
                    self.appState.objectWillChange.send()
                    self.appState.selectedConversation.title = response.response.capitalized
                }
            }
        }
    }

    func sendMessage(message: Message, streaming: Bool) async {
        DispatchQueue.main.sync {
            self.appState.selectedConversation.messages.append(message)
            self.appState.isModelResponding = true
        }
        await sendGenerateResponseRequest(streaming: streaming)
    }

    func sendGenerateResponseRequest(streaming: Bool) async {
        do {
            if streaming {
                try await repository.generateResponseStreaming(model: appState.modelName, with: appState.selectedConversation.messages, handler: handleSendMessageResponseStreaming)
            } else {
                try repository.generateResponse(model: appState.modelName, with: appState.selectedConversation.messages, handler: handleSendMessageResponse)
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
                withAnimation {
                    self.appState.selectedConversation.messages.append(response.message)
                }
            }
        }
        DispatchQueue.main.sync {
            self.appState.isModelResponding = false
        }
    }

    func handleSendMessageResponseStreaming(line: String) {
        if let jsonData = line.data(using: .utf8), let response = try? Response.decoder.decode(Response.self, from: jsonData) {
            if self.appState.selectedConversation.messages.last!.role == .user {
                DispatchQueue.main.sync {
                    self.appState.selectedConversation.messages.append(Message(role: .assistant))
                }
            }
            DispatchQueue.main.sync {
                let lastIndex = self.appState.selectedConversation.messages.endIndex - 1
                self.appState.objectWillChange.send()
                self.appState.selectedConversation.messages[lastIndex].content += response.message.content
                if response.done {
                    self.appState.isModelResponding = false
                    if self.appState.selectedConversation.messages.count == 2 {
                        self.updateCurrentConversationTitle(basedOn: self.appState.selectedConversation.messages)
                    }
                }
            }
        }
    }

    func regenerateMessage(at selectedMessageIndex: Int, streaming: Bool) async {
        DispatchQueue.main.sync {
            withAnimation {
                self.appState.selectedConversation.messages.removeSubrange(selectedMessageIndex...)
                self.appState.isModelResponding = true
            }
        }
        await sendGenerateResponseRequest(streaming: streaming)
    }
}
