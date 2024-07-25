//
//  Message.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

enum Role: String, Codable, Hashable {
    case user, assistant
}

struct Message: Codable, Hashable {
    var timestamp: Date
    var role: Role
    var content: String

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case role
        case content
    }

    init(timestamp: Date = .now, role: Role, content: String = "") {
        self.timestamp = timestamp
        self.content = content
        self.role = role
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = .now
        role = try values.decode(Role.self, forKey: .role)
        content = try values.decode(String.self, forKey: .content)
    }

    func encode(to encoder: any Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(role, forKey: .role)
        try values.encode(content, forKey: .content)
    }
}
