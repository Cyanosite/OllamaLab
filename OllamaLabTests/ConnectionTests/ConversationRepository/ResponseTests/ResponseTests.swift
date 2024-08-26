//
//  ResponseTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import XCTest
@testable import OllamaLab

final class ResponseTests: XCTestCase {
    func test_decode_withStreaming_shouldSucceed() throws {
        let json = {
            var json = """
            {
              "model": "llama3",
              "created_at": "2023-08-04T08:52:19.385406455-07:00",
              "message": {
                "role": "assistant",
                "content": "Hello!",
                "images": null
              },
              "done": false
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let data = json.data(using: .utf8)!
        let response = try Response.decoder.decode(Response.self, from: data)
        XCTAssertEqual(response.model, "llama3")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1691164339).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.message.content, "Hello!")
        XCTAssertEqual(response.message.role, .assistant)
        XCTAssertFalse(response.done)
    }

    func test_decode_withoutStreaming_shouldSucceed() throws {
        let json = {
            var json = """
            {
              "model": "llama3",
              "created_at": "2023-12-12T14:13:43.416799Z",
              "message": {
                "role": "assistant",
                "content": "Hello"
              },
              "done": true,
              "total_duration": 5191566416,
              "load_duration": 2154458,
              "prompt_eval_count": 26,
              "prompt_eval_duration": 383809000,
              "eval_count": 298,
              "eval_duration": 4799921000
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let data = json.data(using: .utf8)!
        let response = try Response.decoder.decode(Response.self, from: data)
        XCTAssertEqual(response.model, "llama3")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1702390423).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.message.content, "Hello")
        XCTAssertEqual(response.message.role, .assistant)
        XCTAssertTrue(response.done)
        let duration = try XCTUnwrap(response.duration)
        XCTAssertEqual(duration, .nanoseconds(5191566416))
    }
}
