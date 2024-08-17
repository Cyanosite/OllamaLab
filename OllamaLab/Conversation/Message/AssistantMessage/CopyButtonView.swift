//
//  CopyButton.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct CopyButtonView: View {
    @State private var isHovering = false
    @State private var iconSystemName = "doc.on.clipboard"
    var messageContent: String

    var body: some View {
        Button {
            NSPasteboard.general.clearContents()
            withAnimation(.bouncy) {
                iconSystemName = "checkmark"
            }
            NSPasteboard.general.setString(messageContent, forType: .string)
        } label: {
            Image(systemName: iconSystemName)
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
    CopyButtonView(messageContent: "Hello! How can I assist you today?").padding()
}
