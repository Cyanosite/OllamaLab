//
//  TagsResponse.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import Foundation

struct TagsResponse: Decodable {
    let models: [Tag]

    static let decoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: dateString)!
        })
        return jsonDecoder
    }()
}

struct Tag: Decodable {
    let name: String
    let modifiedDate: Date
    let size: Int64

    private enum CodingKeys: String, CodingKey {
        case name
        case modified_at
        case size
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        modifiedDate = try values.decode(Date.self, forKey: .modified_at)
        size = try values.decode(Int64.self, forKey: .size)
    }
}
