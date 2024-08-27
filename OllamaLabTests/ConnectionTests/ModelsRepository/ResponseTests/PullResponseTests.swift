//
//  PullResponseTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 27/08/2024.
//

import XCTest
@testable import OllamaLab

final class PullResponseTests: XCTestCase {
    func test_decode_withValidJson_shouldSucceed() throws {
        let json = """
        {
          "status": "downloading digestname",
          "digest": "digestname",
          "total": 2142590208,
          "completed": 241970
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(PullResponse.self, from: data)
        XCTAssertEqual(decoded.status, "downloading digestname")
        XCTAssertEqual(decoded.digest, "digestname")
        XCTAssertEqual(decoded.total, 2142590208)
        XCTAssertEqual(decoded.completed, 241970)
    }

    func test_decode_withMissingDataFromJson_shouldSucceed() throws {
        let json = """
        {
          "status": "success"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(PullResponse.self, from: data)
        XCTAssertEqual(decoded.status, "success")
        XCTAssertNil(decoded.digest)
        XCTAssertNil(decoded.total)
        XCTAssertNil(decoded.completed)
    }

    func test_decode_withError_shouldSucceed() throws {
        let json = """
        {
          "error": "pull model manifest: file does not exist"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(PullResponse.self, from: data)
        XCTAssertEqual(decoded.error, "pull model manifest: file does not exist")
    }
}
