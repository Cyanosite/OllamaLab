//
//  ModelsInteractorProtocol.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import Foundation

protocol ModelsInteractorProtocol {
    func fetchTags() async
    func delete(tag: String) async throws
    func pull(tag: String, handler: @escaping (Data) async -> ()) async throws
    func removeLastModel()
}
