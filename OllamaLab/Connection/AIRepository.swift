//
//  AIRepository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

final class AIRepository: Repository {
    @AppStorage("baseURL") private var _baseURL = "http://localhost:11434"
    var baseURL: String {
        get {
            _baseURL + "/api"
        }
    }
    let jsonEncoder = JSONEncoder()
    let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    @MainActor
    func handleClientError(_ error: (any Error)?) {
        showErrorMessage(message: "A client side network error has occurred.")
    }

    @MainActor
    func handleServerError(_ error: URLResponse?) {

    }

    @MainActor
    func showErrorMessage(message: String = "") {
        withAnimation {
            self.appState.alertMessage = message.isEmpty ? "An error has occurred" : message
            self.appState.isAlertShowing = true
            self.appState.isModelResponding = false
        }
    }

    func sendRequest(to endpoint: String, with payload: Data, handler: @escaping (Data) async -> ()) {
        let url = URL(string: "\(baseURL)/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
            if let error = error {
                Task {
                    await self.handleClientError(error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                Task {
                    await self.handleServerError(response)
                }
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let data = data {
                Task(priority: .userInitiated) {
                    await handler(data)
                }
            }
        }
        task.resume()
    }

    func generateResponse(model: String, with history: [Message], handler: @escaping (Data) async -> ()) throws {
        let request = Request(model: model, messages: history, stream: false)
        let requestJSON = try jsonEncoder.encode(request)
        sendRequest(to: "/chat", with: requestJSON, handler: handler)
    }

    func sendRequestStreaming(to endpoint: String, with payload: Data, handler: @escaping (UUID, String) async -> (), messageID: UUID) async throws {
        let url = URL(string: "\(baseURL)/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        for try await line in stream.lines {
            await handler(messageID, line)
        }
    }

    func generateResponseStreaming(model: String, with history: [Message], handler: @escaping (UUID, String) async -> (), messageID: UUID) async throws {
        let request = Request(model: model, messages: history)
        let requestJSON = try jsonEncoder.encode(request)
        try await sendRequestStreaming(to: "/chat", with: requestJSON, handler: handler, messageID: messageID)
    }

    func sendCompletionRequest(with payload: Data, handler: @escaping (Data) async -> ()) {
        let url = URL(string: "\(baseURL)/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
            if let error = error {
                Task {
                    await self.handleClientError(error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                Task {
                    await self.handleServerError(response)
                }
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let data = data {
                Task(priority: .background) {
                    await handler(data)
                }
            }
        }
        task.resume()
    }

    func generateCompletion(model: String, with prompt: String, handler: @escaping (Data) async -> ()) throws {
        let request = CompletionRequest(model: model, prompt: prompt)
        let requestJSON = try jsonEncoder.encode(request)
        sendCompletionRequest(with: requestJSON, handler: handler)
    }
}
