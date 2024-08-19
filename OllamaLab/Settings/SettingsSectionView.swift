//
//  SettingsSectionView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 19/08/2024.
//

import SwiftUI

struct SettingsSectionView<Content: View>: View {
    let sectionTitle: String
    @ViewBuilder let SectionContent: () -> Content

    init(_ sectionTitle: String, @ViewBuilder content : @escaping () -> Content) {
        self.sectionTitle = sectionTitle
        self.SectionContent = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(sectionTitle)
                .padding(.horizontal, 25)
            VStack {
                SectionContent()
            }
            .padding(.vertical, 5)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 15)
    }
}

#Preview {
    SettingsSectionView("App") {
        SettingView(systemImage: "globe", setting: "isSomething") {
            Text("hi")
        }
        Divider()
            .padding(.horizontal, 10)
        SettingView(systemImage: "bubble.left", setting: "isSomething") {
            Text("hi")
        }
    }
}
