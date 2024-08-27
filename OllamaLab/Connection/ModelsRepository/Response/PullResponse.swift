//
//  PullResponse.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 27/08/2024.
//

struct PullResponse: Decodable {
    let status: String?
    let digest: String?
    let total: UInt64?
    let completed: UInt64?
    let error: String?
}
