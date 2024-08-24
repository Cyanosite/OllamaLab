//
//  Interactors.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct Interactors: EnvironmentKey {
    let appState: AppState
    let conversationInteractor: ConversationInteractorProtocol

    static let defaultValue: Interactors = {
        let appState = AppState()
        return Interactors(appState: appState, conversationInteractor: ConversationInteractor(appState: appState))
    }()
}

extension EnvironmentValues {
    var interactors: Interactors {
        get { self[Interactors.self] }
        set { self[Interactors.self] = newValue }
    }
}
