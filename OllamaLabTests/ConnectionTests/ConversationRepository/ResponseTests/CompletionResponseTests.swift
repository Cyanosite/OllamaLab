//
//  CompletionResponseTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import XCTest
@testable import OllamaLab

final class CompletionResponseTests: XCTestCase {
    func test_decode_withStreaming_shouldSucceed() throws {
        let json = {
            var json = """
            {
              "model": "llama3",
              "created_at": "2023-08-04T08:52:19.385406455-07:00",
              "response": "The",
              "done": false
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let data = json.data(using: .utf8)!
        let response = try CompletionResponse.decoder.decode(CompletionResponse.self, from: data)
        XCTAssertEqual(response.model, "llama3")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1691164339).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.response, "The")
        XCTAssertFalse(response.done)
    }

    func test_decode_withoutStreaming_shouldSucceed() throws {
        let json = {
            var json = """
            {
              "model": "llama3",
              "created_at": "2023-08-04T19:22:45.499127Z",
              "response": "Hi.",
              "done": true,
              "context": [1, 2, 3],
              "total_duration": 5043500667,
              "load_duration": 5025959,
              "prompt_eval_count": 26,
              "prompt_eval_duration": 325953000,
              "eval_count": 290,
              "eval_duration": 4709213000
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let data = json.data(using: .utf8)!
        let response = try Response.decoder.decode(CompletionResponse.self, from: data)
        XCTAssertEqual(response.model, "llama3")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1691176965).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.response, "Hi.")
        XCTAssertTrue(response.done)
        XCTAssertEqual(response.duration, .nanoseconds(5043500667))
    }
}
