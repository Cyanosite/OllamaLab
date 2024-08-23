//
//  Response.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation

struct Response: Decodable {
    let model: String
    let creationDate: Date
    let message: DecodedMessage
    let done: Bool
    let duration: Duration?

    private enum CodingKeys: String, CodingKey {
        case model
        case created_at
        case message
        case done
        case total_duration
        case load_duration
        case prompt_eval_count
        case prompt_eval_duration
        case eval_count
        case eval_duration
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        model = try values.decode(String.self, forKey: .model)
        creationDate = try values.decode(Date.self, forKey: .created_at)
        message = try values.decode(DecodedMessage.self, forKey: .message)
        done = try values.decode(Bool.self, forKey: .done)
        if let totalDuration = try values.decodeIfPresent(UInt64.self, forKey: .total_duration) {
            duration = .nanoseconds(totalDuration)
        } else {
            duration = nil
        }
    }

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

struct CompletionResponse: Decodable {
    let model: String
    let creationDate: Date
    let response: String
    let duration: Duration?

    private enum CodingKeys: String, CodingKey {
        case model
        case created_at
        case response
        case done
        case total_duration
        case load_duration
        case prompt_eval_count
        case prompt_eval_duration
        case eval_count
        case eval_duration
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        model = try values.decode(String.self, forKey: .model)
        creationDate = try values.decode(Date.self, forKey: .created_at)
        response = try values.decode(String.self, forKey: .response)
        if let totalDuration = try values.decodeIfPresent(UInt64.self, forKey: .total_duration) {
            duration = .nanoseconds(totalDuration)
        } else {
            duration = nil
        }
    }

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
