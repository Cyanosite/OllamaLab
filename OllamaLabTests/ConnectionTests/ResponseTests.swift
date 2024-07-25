//
//  ResponseTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import XCTest
@testable import OllamaLab

final class ResponseTests: XCTestCase {
    let json = {
        var json = """
        {
          "model": "llama3",
          "created_at": "2024-07-20T17:24:51.948123Z",
          "message": {
            "role": "assistant",
            "content": "Hello!"
          },
          "done_reason": "stop",
          "done": true,
          "total_duration": 1146680584,
          "load_duration": 32087250,
          "prompt_eval_count": 11,
          "prompt_eval_duration": 302065000,
          "eval_count": 26,
          "eval_duration": 811536000
        }
        """
        json.removeAll {
            $0.isWhitespace
        }
        return json
    }()

    let streamingJson = "{\"model\":\"llama3.1\",\"created_at\":\"2024-08-12T15:08:16.438152Z\",\"message\":{\"role\":\"assistant\",\"content\":\"Hello\"},\"done\":false}\n"

    func testDecodable() throws {
        let data = json.data(using: .utf8)!
        let response = try Response.decoder.decode(Response.self, from: data)
        XCTAssertEqual(response.model, "llama3")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1721496291).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.message.content, "Hello!")
        XCTAssertEqual(response.message.role, .assistant)
        XCTAssertTrue(response.done)
        let duration = try XCTUnwrap(response.duration)
        XCTAssertEqual(duration, .nanoseconds(1146680584))
    }

    func testDecodableStreaming() throws {
        let data = streamingJson.data(using: .utf8)!
        let response = try Response.decoder.decode(Response.self, from: data)
        XCTAssertEqual(response.model, "llama3.1")
        XCTAssertEqual(response.creationDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1723475296).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(response.message.content, "Hello")
        XCTAssertEqual(response.message.role, .assistant)
        XCTAssertFalse(response.done)
        XCTAssertNil(response.duration)
    }

    let completionJson = "{\"model\":\"llama3.1\",\"created_at\":\"2024-08-14T12:31:30.087306Z\",\"response\":\"Title\",\"done\":true,\"done_reason\":\"stop\",\"context\":[128006,882,128007,271,40,1097,264,2254,3544,4221,1646,4401,4871,264,6369,3851,323,358,1390,311,7068,264,1633,2875,2316,369,279,1217,596,10652,11,358,690,1893,264,5743,3492,2316,3196,389,279,1217,596,1176,1984,11,1217,1984,25,15960,128009,128006,78191,128007,271,29815,389,279,1217,596,1176,1984,330,6151,498,1618,374,264,3284,2875,2316,369,872,10652,1473,1,9906,1875,2028,374,264,4382,323,31439,2316,430,27053,279,43213,7138,315,279,1217,596,1176,1984,13],\"total_duration\":4178344042,\"load_duration\":1817774625,\"prompt_eval_count\":56,\"prompt_eval_duration\":279120000,\"eval_count\":43,\"eval_duration\":2078356000}"

    func testDecodableCompletionResponse() throws {
        let data = completionJson.data(using: .utf8)!
        let response = try Response.decoder.decode(CompletionResponse.self, from: data)
        XCTAssertEqual(response.model, "llama3.1")
        XCTAssertEqual(response.response, "Title")
    }
}
