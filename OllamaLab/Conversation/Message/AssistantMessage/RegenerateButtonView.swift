//
//  RegenerateButton.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct RegenerateButtonView: View {
    @Environment(\.interactors) var interactors: Interactors
    @State private var isHovering = false
    let selectedMessageIndex: Int

    var body: some View {
        Button {
            Task {
                await interactors.conversationInteractor.regenerateMessage(at: selectedMessageIndex, streaming: true)
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
        }
        .foregroundStyle(isHovering ? .white : .gray)
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isHovering = isHovering
            }
        }
    }
}

#Preview {
    RegenerateButtonView(selectedMessageIndex: 0)
}
