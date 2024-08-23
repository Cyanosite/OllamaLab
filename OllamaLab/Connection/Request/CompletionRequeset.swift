//
//  CompletionRequeset.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 23/08/2024.
//

struct CompletionRequest: Encodable {
    let model: String
    let prompt: String
    let stream: Bool = false
}
