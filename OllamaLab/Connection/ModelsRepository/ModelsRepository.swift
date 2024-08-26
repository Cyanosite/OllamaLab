//
//  RealModelsRepository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 26/08/2024.
//

import Foundation
import SwiftUI

final class ModelsRepository: ModelsRepositoryProtocol {
    @AppStorage("baseURL") private var _baseURL = "http://localhost:11434"
    var baseURL: String {
        get {
            _baseURL + "/api"
        }
    }

    func getTags() async -> [String] {
        let url = URL(string: baseURL + "/tags")
        guard let url else {
            return []
        }
        let request = URLRequest(url: url)
        let response = try? await URLSession.shared.data(for: request)
        guard let data = response?.0 else {
            return []
        }
        let models = try? TagsResponse.decoder.decode(TagsResponse.self, from: data)
        guard let models else {
            return []
        }
        let modelNames = models.models.map { $0.name }
        print(modelNames)
        return modelNames
    }
}
