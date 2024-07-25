//
//  Repository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation

protocol Repository {
    func generateResponse(model: String, with history: [Message], handler: @escaping (Data) -> ()) throws
    func generateResponseStreaming(model: String, with history: [Message], handler: @escaping (String) -> ()) async throws
    func generateCompletion(model: String, with prompt: String, handler: @escaping (Data) -> ()) throws
}
