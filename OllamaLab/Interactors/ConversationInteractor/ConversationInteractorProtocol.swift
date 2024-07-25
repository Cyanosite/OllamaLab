//
//  ConversationInteractorProtocol.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation

protocol ConversationInteractorProtocol {
    func addNewConversation(conversation: Conversation)
    func newConversation()
    func updateSelectedConversation(conversation: Conversation)
    func sendMessage(message: Message, streaming: Bool) async
    func regenerateMessage(at selectedMessageIndex: Int, streaming: Bool) async
}
