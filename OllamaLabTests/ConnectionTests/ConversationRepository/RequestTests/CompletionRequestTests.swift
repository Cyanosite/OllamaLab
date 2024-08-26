//
//  CompletionRequestTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import XCTest
@testable import OllamaLab

final class CompletionRequestTests: XCTestCase {
    let modelName = "llama3"
    let encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    func testInit() throws {
        let request = CompletionRequest(model: "llama3", prompt: "hi", stream: true)

        XCTAssertEqual(request.model, modelName)
        XCTAssertEqual(request.prompt, "hi")
        let stream = try XCTUnwrap(request.stream)
        XCTAssertTrue(stream)
    }

    func testInitWithoutStream() {
        let request = CompletionRequest(model: modelName, prompt: "hi")

        XCTAssertEqual(request.model, modelName)
        XCTAssertEqual(request.prompt, "hi")
        XCTAssertNil(request.stream)
    }

    func testEncodable() throws {
        let json = {
            var json = """
            {
              "model": "llama3",
              "prompt": "Hi",
              "stream": false
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let request = CompletionRequest(model: modelName, prompt: "Hi", stream: false)

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
              "model": "llama3",
              "prompt": "Hi"
            }
            """
            json.removeAll {
                $0.isWhitespace
            }
            return json
        }()
        let request = CompletionRequest(model: modelName, prompt: "Hi")

        if let encoded = try? encoder.encode(request) {
            let string = String(data: encoded, encoding: .utf8)
            XCTAssertEqual(string, json)
        } else {
            XCTFail("encoding should succeed")
        }
    }
}
