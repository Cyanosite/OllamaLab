//
//  AppState.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var modelName: String = "llama3.1"
    @Published var isModelResponding = false
    @Published var selectedConversation = Conversation()
    @Published var alertMessage = ""
    @Published var isAlertShowing = false
    var panel: FloatingPanel!
}
