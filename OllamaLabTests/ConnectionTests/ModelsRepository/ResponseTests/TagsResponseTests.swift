//
//  TagsResponseTests.swift
//  OllamaLabTests
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import XCTest
@testable import OllamaLab

final class TagsResponseTests: XCTestCase {
    let json = """
    {
      "models": [
        {
          "name": "codellama:13b",
          "modified_at": "2023-11-04T14:56:49.277302595-07:00",
          "size": 7365960935,
          "digest": "9f438cb9cd581fc025612d27f7c1a6669ff83a8bb0ed86c94fcf4c5440555697",
          "details": {
            "format": "gguf",
            "family": "llama",
            "families": null,
            "parameter_size": "13B",
            "quantization_level": "Q4_0"
          }
        },
        {
          "name": "llama3:latest",
          "modified_at": "2023-12-07T09:32:18.757212583-08:00",
          "size": 3825819519,
          "digest": "fe938a131f40e6f6d40083c9f0f430a515233eb2edaa6d72eb85c50d64f2300e",
          "details": {
            "format": "gguf",
            "family": "llama",
            "families": null,
            "parameter_size": "7B",
            "quantization_level": "Q4_0"
          }
        }
      ]
    }
    """

    func testDecode() throws {
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try TagsResponse.decoder.decode(TagsResponse.self, from: data)
        XCTAssertEqual(decoded.models.count, 2)
        guard let first = decoded.models.first else {
            XCTFail("First model not found, 2 should have been found")
            return
        }
        XCTAssertEqual(first.name, "codellama:13b")
        XCTAssertEqual(first.modifiedDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1699135009).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(first.size, 7365960935)
        guard let second = decoded.models.last else {
            XCTFail("Second model not found, 2 should have been found")
            return
        }
        XCTAssertEqual(second.name, "llama3:latest")
        XCTAssertEqual(second.modifiedDate.timeIntervalSince1970, Date(timeIntervalSince1970: 1701970338
).timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(second.size, 3825819519)
    }
}
