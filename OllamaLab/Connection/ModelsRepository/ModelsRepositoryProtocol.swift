//
//  ModelsRepository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import Foundation

protocol ModelsRepositoryProtocol {
    func getTags() async -> [String]
}
