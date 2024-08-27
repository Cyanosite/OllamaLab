//
//  DeleteRequestTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 27/08/2024.
//

import XCTest
@testable import OllamaLab

final class ModelRequestTests: XCTestCase {
    func test_encode_withValidData_shouldSucceed() throws {
        let json = {
            var json = """
            {
              "name": "llama3:13b"
            }
            """
            json.removeAll(where: { $0.isWhitespace })
            return json
        }()
        let request = ModelRequest(name: "llama3:13b")
        let encoded = try JSONEncoder().encode(request)
        let string = String(data: encoded, encoding: .utf8)
        XCTAssertEqual(string, json)
    }
}
