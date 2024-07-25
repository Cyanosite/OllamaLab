//
//  AssistantMessageView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 25/07/2024.
//

import SwiftUI
import AppKit

struct AssistantMessageView: View {
    @State private var isOptionsShowing = false
    @State private var isMessageCopied = false
    var message: Message
    let messageIndex: Int
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .padding(.horizontal, 10)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(message.content))
                    .textSelection(.enabled)
                    .lineSpacing(3)
                    .padding(.bottom, 25)
            }
            .overlay(alignment: .bottom) {
                if isOptionsShowing {
                    HStack(spacing: 12) {
                        CopyButtonView(messageContent: message.content)
                        RegenerateButtonView(selectedMessageIndex: messageIndex)
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .onHover { isHovering in
            withAnimation {
                isOptionsShowing = isHovering
            }
        }
    }
}

#Preview("Short assistant message") {
    ScrollView {
        AssistantMessageView(message: Message(role: .assistant, content: "Hi! How's your day going so far? Is there something I can help you with or would you like to chat?"), messageIndex: 0)
        Spacer()
    }
}

#Preview("Long assistant message") {
    ScrollView {
        AssistantMessageView(message: Message(role: .assistant, content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean sed nunc eros. Nullam id tincidunt nulla. Quisque nec ante vitae arcu placerat blandit. Nam hendrerit, metus feugiat congue facilisis, nulla nisl luctus massa, vitae molestie quam purus sit amet nulla. Donec elit elit, elementum sed justo fringilla, tempor ornare magna. Fusce vel porta ipsum, at varius nibh. Nullam neque diam, rutrum at tempor eu, efficitur vitae elit. Etiam congue pellentesque tellus non aliquet. Curabitur eget lacus sollicitudin, tristique tellus eget, tincidunt nunc. Maecenas non bibendum metus. Maecenas molestie, nisi in tincidunt laoreet, ipsum nisl semper tellus, id lobortis neque urna ut lectus. Etiam porta ante sit amet tempor eleifend. Vivamus turpis quam, finibus ac velit ac, iaculis tristique enim. Fusce ac velit id mi finibus pharetra. Vestibulum venenatis malesuada urna, et aliquam eros."), messageIndex: 0)
        Spacer()
    }
}
