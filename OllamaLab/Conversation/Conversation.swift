//
//  Conversation.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftData

@Model
final class Conversation: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var creationDate: Date
    var title: String
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message]?

    init(id: UUID = UUID(), creationDate: Date = .now, title: String = "", messages: [Message]? = nil) {
        self.id = id
        self.creationDate = creationDate
        self.title = title
        self.messages = messages
    }

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
