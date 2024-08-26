//
//  Repository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation

protocol ConversationRepositoryProtocol {
    func generateResponse(model: String, with history: [Message], handler: @escaping (Data) async -> ()) throws
    func generateResponseStreaming(model: String, with history: [Message], handler: @escaping (UUID, String) async -> (), messageID: UUID) async throws
    func generateCompletion(model: String, with prompt: String, handler: @escaping (Data) async -> ()) throws
}
