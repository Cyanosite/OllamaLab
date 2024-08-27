//
//  ModelsView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 27/08/2024.
//

import SwiftUI

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.interactors) private var interactors
    @State private var selectedModel = ""
    @State private var isAlertShowing = false
    @State private var alertMessage = ""
    @State private var isAddingNewModel = false
    @State private var newModelName = ""
    @State private var isNewModelNameEmpty = true
    @State private var isPullingModel = false
    @State private var pullingModelStatus = ""
    @State private var pullingModelTotal: UInt64 = 1
    @State private var pullingModelValue: UInt64 = 0
    private var progressValue: Double {
        get {
            Double(pullingModelValue) / Double(pullingModelTotal)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            List(appState.models, id: \.self, selection: $selectedModel) { model in
                HStack {
                    Text(model)
                        .textSelection(.enabled)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .padding(5)
                        .swipeActions {
                            Button {
                                deleteModel(tag: model)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                                    .tint(.red)
                            }
                        }
                    if isPullingModel && model == appState.models.last {
                        ProgressView(value: progressValue, total: 1.0) {
                            Text("Status: \(pullingModelStatus)")
                        }
                    }
                }
            }
            if isAddingNewModel {
                HStack {
                    Button {
                        withAnimation {
                            isAddingNewModel = false
                        }
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(SendMessageButtonStyle())
                    TextField("modelName:tag", text: $newModelName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                        .padding(8)
                        .padding(.horizontal, 5)
                        .background {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke()
                        }
                        .onSubmit {
                            pullModel(tag: newModelName)
                        }
                        .onChange(of: newModelName) {
                            withAnimation(.bouncy) {
                                isNewModelNameEmpty = newModelName.isEmpty
                            }
                        }
                    if !isNewModelNameEmpty {
                        Button {
                            pullModel(tag: newModelName)
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                        }
                        .buttonStyle(SendMessageButtonStyle())
                        .transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
                    }
                }
                .transition(.move(edge: .bottom))
                .padding(5)
            }
        }
        .alert(alertMessage, isPresented: $isAlertShowing) {
            Button("Ok", role: .cancel) {
                alertMessage = ""
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    withAnimation {
                        isAddingNewModel = true
                    }
                } label: {
                    Label("Add new model", systemImage: "arrow.down.square")
                        .labelStyle(.titleAndIcon)
                }
                Text("Add new model")
            }
        }
        .navigationTitle("Manage models")
        .frame(minWidth: 600, minHeight: 300)
    }

    private func deleteModel(tag: String) {
        Task(priority: .userInitiated) {
            do {
                try await interactors.modelsInteractor.delete(tag: tag)
            } catch let error {
                switch error as? DeleteModelError {
                case .encoding:
                    alertMessage = "Failed to encode delete request"
                case .modelNotFound:
                    alertMessage = "Model requested for deletion not found"
                case .network:
                    alertMessage = "A network error has occurred while trying to delete the model"
                case .unknown:
                    alertMessage = "An unknown error has occurred while trying to delete the model"
                case .none:
                    return
                }
                isAlertShowing = true
            }
        }
    }

    private func pullModel(tag: String) {
        withAnimation {
            newModelName = ""
            isAddingNewModel = false
        }
        guard !isNewModelNameEmpty else {
            alertMessage = "Enter a the name of the model to pull"
            isAlertShowing = true
            return
        }

        Task(priority: .userInitiated) {
            do {
                try await interactors.modelsInteractor.pull(tag: tag, handler: pullModelHandler)
            } catch let error {
                switch error as? PullModelError {
                case .encoding:
                    alertMessage = "Failed to encode pull request"
                case .decoding:
                    alertMessage = "Failed to decode response"
                case .network:
                    alertMessage = "A network error has occurred while trying to delete the model"
                case .none:
                    return
                }
                isAlertShowing = true
            }
        }
    }

    private func pullModelHandler(data: Data) {
        withAnimation {
            isPullingModel = true
        }
        guard let decoded = try? JSONDecoder().decode(PullResponse.self, from: data) else {
            alertMessage = "Error while decoding progress"
            isAlertShowing = true
            resetPullModel()
            return
        }
        withAnimation {
            if let status = decoded.status {
                pullingModelStatus = status
                if let total = decoded.total, let completed = decoded.completed {
                    pullingModelTotal = total
                    pullingModelValue = completed
                }
            } else if let error = decoded.error {
                alertMessage = error
                isAlertShowing = true
                resetPullModel()
                return
            } else {
                alertMessage = "Invalid decoded JSON"
                isAlertShowing = true
                resetPullModel()
                return
            }
        }
        if decoded.status == "success" {
            withAnimation {
                isPullingModel = false
                pullingModelTotal = 1
                pullingModelValue = 0
            }
        }
    }

    private func resetPullModel() {
        withAnimation {
            isPullingModel = false
            isAddingNewModel = false
            appState.models.removeLast()
        }
    }
}

#Preview {
    let appState = AppState()
    appState.models = ["mistral-nemo:latest", "llama3.1:latest"]
    let interactors = Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState), modelsInteractor: ModelsInteractor(appState: appState))
    return ModelsView()
        .environmentObject(appState)
}
