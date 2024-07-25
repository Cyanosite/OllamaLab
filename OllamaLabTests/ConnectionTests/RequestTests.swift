//
//  RequestTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import XCTest
@testable import OllamaLab

final class RequestTests: XCTestCase {
    let modelName = "llama3"
    let messages = [
        Message(role: .user, content: "hello"),
    ]
    let encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    func testInit() throws {
        let request = Request(model: modelName, messages: messages, stream: false)

        XCTAssertEqual(request.model, modelName)
        XCTAssertEqual(request.messages, messages)
        let stream = try XCTUnwrap(request.stream)
        XCTAssertFalse(stream)
    }

    func testInitWithoutStream() {
        let request = Request(model: modelName, messages: messages)

        XCTAssertEqual(request.model, modelName)
        XCTAssertEqual(request.messages, messages)
        XCTAssertNil(request.stream)
    }

    func testEncodable() throws {
        let json = {
            var json = """
            {
              "messages": [
                {
                  "content": "hello",
                  "role": "user"
                }
              ],
              "model": "llama3",
              "stream": false
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let request = Request(model: modelName, messages: messages, stream: false)

        if let encoded = try? encoder.encode(request) {
            let string = String(data: encoded, encoding: .utf8)
            XCTAssertEqual(string, json)
        } else {
            XCTFail("encoding should succeed")
        }
    }

    func testEncodableWithoutStream() throws {
        let json = {
            var json = """
            {
              "messages": [
                {
                  "content": "hello",
                  "role": "user"
                }
              ],
              "model": "llama3"
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let request = Request(model: modelName, messages: messages)

        if let encoded = try? encoder.encode(request) {
            let string = String(data: encoded, encoding: .utf8)
            XCTAssertEqual(string, json)
        } else {
            XCTFail("encoding should succeed")
        }
    }
}
