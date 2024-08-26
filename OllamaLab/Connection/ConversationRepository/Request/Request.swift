//
//  Request.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

struct Request: Encodable {
    let model: String
    let messages: [Message]
    let stream: Bool?

    init(model: String, messages: [Message], stream: Bool? = nil) {
        self.model = model
        self.messages = messages
        self.stream = stream
    }
}
