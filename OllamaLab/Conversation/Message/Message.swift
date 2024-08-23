//
//  Message.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftData

enum Role: String, Codable, Hashable {
    case user, assistant
}

@Model
final class Message: Encodable, Hashable {
    @Attribute(.unique) var id: UUID
    var conversation: Conversation?
    var timestamp: Date
    var role: Role
    var content: String

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case role
        case content
    }

    init(id: UUID = UUID(), conversation: Conversation, timestamp: Date = .now, role: Role, content: String = "") {
        self.id = id
        self.conversation = conversation
        self.timestamp = timestamp
        self.content = content
        self.role = role
    }

    init(id: UUID = UUID(), conversation: Conversation, message: DecodedMessage) {
        self.id = id
        self.conversation = conversation
        self.timestamp = message.timestamp
        self.role = message.role
        self.content = message.content
    }

    func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(role, forKey: .role)
        try values.encode(content, forKey: .content)
    }
}
