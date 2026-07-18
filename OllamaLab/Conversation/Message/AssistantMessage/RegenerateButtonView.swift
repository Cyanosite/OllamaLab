//
//  RegenerateButton.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct RegenerateButtonView: View {
    @Environment(\.interactors) var interactors: Interactors
    let selectedMessageIndex: Int

    var body: some View {
        Button {
            Task {
                await interactors.conversationInteractor.regenerateMessage(at: selectedMessageIndex, streaming: true)
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.small)
    }
}

#Preview {
    RegenerateButtonView(selectedMessageIndex: 0).padding()
}
