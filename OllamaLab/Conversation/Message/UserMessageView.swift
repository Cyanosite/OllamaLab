//
//  UserMessageView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI

struct UserMessageView: View {
    var message: Message
    var body: some View {
        HStack {
            Spacer()
            Text(message.content)
                .padding(5)
                .padding(.horizontal, 5)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(message.role == .user ? .blue : .gray)
                }
                .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
    }
}

#Preview("Short user message") {
    ScrollView {
        UserMessageView(message: Message(role: .user, content: "Hello, World!"))
    }
}
