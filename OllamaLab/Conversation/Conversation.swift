//
//  Conversation.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

final class Conversation: ObservableObject, Identifiable, Hashable {
    var id = UUID()
    var creationDate: Date = .now
    @Published var title: String = ""
    @Published var messages: [Message] = []

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
