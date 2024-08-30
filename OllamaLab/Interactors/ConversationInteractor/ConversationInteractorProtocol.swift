//
//  ConversationInteractorProtocol.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation

protocol ConversationInteractorProtocol {
    @MainActor func newConversation()
    func sendMessage(role: Role, content: String, streaming: Bool) async
    func regenerateMessage(at selectedMessageIndex: Int, streaming: Bool) async
}
