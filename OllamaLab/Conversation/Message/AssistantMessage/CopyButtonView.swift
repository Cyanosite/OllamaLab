//
//  CopyButton.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 15/08/2024.
//

import SwiftUI

struct CopyButtonView: View {
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
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.small)
    }
}

#Preview {
    CopyButtonView(messageContent: "Hello! How can I assist you today?").padding()
}
