//
//  AIRepository.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

struct AIRepository: Repository {
    @AppStorage("baseURL") private var _baseURL = "http://localhost:11434"
    var baseURL: String {
        get {
            _baseURL + "/api"
        }
    }

    let jsonEncoder = JSONEncoder()

    func sendRequest(to endpoint: String, with payload: Data, handler: @escaping (Data) -> ()) {
        let url = URL(string: "\(baseURL)/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
            if let error = error {
                //self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                //self.handleServerError(response)
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let data = data {
                DispatchQueue.global(qos: .userInteractive).async {
                    handler(data)
                }
            }
        }
        task.resume()
    }

    func generateResponse(model: String, with history: [Message], handler: @escaping (Data) -> ()) throws {
        let request = Request(model: model, messages: history, stream: false)
        let requestJSON = try jsonEncoder.encode(request)
        sendRequest(to: "/chat", with: requestJSON, handler: handler)
    }

    func sendRequestStreaming(to endpoint: String, with payload: Data, handler: @escaping (String) -> ()) async throws {
        let url = URL(string: "\(baseURL)/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
        let (stream, _) = try await URLSession.shared.bytes(for: request)
        for try await line in stream.lines {
            DispatchQueue.global(qos: .userInteractive).async {
                handler(line)
            }
        }
    }

    func generateResponseStreaming(model: String, with history: [Message], handler: @escaping (String) -> ()) async throws {
        let request = Request(model: model, messages: history)
        let requestJSON = try jsonEncoder.encode(request)
        try await sendRequestStreaming(to: "/chat", with: requestJSON, handler: handler)
    }

    func sendCompletionRequest(with payload: Data, handler: @escaping (Data) -> ()) {
        let url = URL(string: "\(baseURL)/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.uploadTask(with: request, from: payload) { data, response, error in
            if let error = error {
                //self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                //self.handleServerError(response)
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
               let data = data {
                DispatchQueue.global(qos: .userInteractive).async {
                    handler(data)
                }
            }
        }
        task.resume()
    }

    func generateCompletion(model: String, with prompt: String, handler: @escaping (Data) -> ()) throws {
        let request = CompletionRequest(model: model, prompt: prompt)
        let requestJSON = try jsonEncoder.encode(request)
        sendCompletionRequest(with: requestJSON, handler: handler)
    }
}
