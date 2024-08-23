//
//  DecodedMessage.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 23/08/2024.
//

import Foundation

/// Used as an intermediate object when decoding a response
struct DecodedMessage: Decodable {
    var timestamp: Date
    var role: Role
    var content: String

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case role
        case content
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = .now
        role = try values.decode(Role.self, forKey: .role)
        content = try values.decode(String.self, forKey: .content)
    }
}
