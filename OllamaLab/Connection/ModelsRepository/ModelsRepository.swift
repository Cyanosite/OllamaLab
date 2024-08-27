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
    let encoder = JSONEncoder()

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
        return modelNames
    }

    // TODO: Add typed throws in Swift6
    func delete(tag: String) async throws {
        let url = URL(string: baseURL + "/delete")
        guard let url else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try? encoder.encode(ModelRequest(name: tag))
        guard let data else {
            throw DeleteModelError.encoding
        }

        do {
            let (_, response) = try await URLSession.shared.upload(for: request, from: data)
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    return
                case 404:
                    throw DeleteModelError.modelNotFound
                default:
                    print(response.statusCode)
                    throw DeleteModelError.unknown
                }
            }
        }
        catch let error where error is DeleteModelError {
            throw error
        } catch {
            throw DeleteModelError.network
        }
    }

    func pull(tag: String, handler: @escaping (Data) async -> ()) async throws {
        let url = URL(string: baseURL + "/pull")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let body = try? encoder.encode(ModelRequest(name: tag)) else {
            throw PullModelError.encoding
        }
        request.httpBody = body
        do {
            let (stream, _) = try await URLSession.shared.bytes(for: request)
            for try await line in stream.lines {
                guard let data = line.data(using: .utf8) else {
                    throw PullModelError.decoding
                }
                await handler(data)
            }
        } catch let error where error is PullModelError {
            throw error
        } catch {
            throw PullModelError.network
        }
    }
}
