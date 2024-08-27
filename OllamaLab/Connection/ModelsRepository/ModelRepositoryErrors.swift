//
//  ModelRepositoryErrors.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 27/08/2024.
//

enum DeleteModelError: Error {
    case encoding
    case network
    case modelNotFound
    case unknown
}

enum PullModelError: Error {
    case encoding
    case decoding
    case network
}
