//
//  ModelsInteractor.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import SwiftUI

final class ModelsInteractor: ModelsInteractorProtocol {
    let appState: AppState
    let modelsRepository: ModelsRepositoryProtocol

    init(appState: AppState) {
        self.appState = appState
        self.modelsRepository = ModelsRepository()
    }

    @MainActor
    func fetchTags() async {
        appState.models = await modelsRepository.getTags()
        if let first = appState.models.first {
            if let llama = appState.models.first(where: { $0.contains("llama3.1") }) {
                appState.selectedModel = llama
            } else {
                appState.selectedModel = first
            }
        } else {
            appState.selectedModel = "Unavailable"
        }
    }

    @MainActor
    func delete(tag: String) async throws {
        try await modelsRepository.delete(tag: tag)
        withAnimation {
            appState.models.removeAll(where: { $0 == tag })
        }
    }

    @MainActor
    func pull(tag: String, handler: @escaping (Data) async -> ()) async throws {
        withAnimation {
            appState.models.append(tag)
        }
        try await modelsRepository.pull(tag: tag, handler: handler)
    }
}
