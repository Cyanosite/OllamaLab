//
//  ModelsInteractor.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import Foundation

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
            appState.selectedModel = first
        }
    }
}
