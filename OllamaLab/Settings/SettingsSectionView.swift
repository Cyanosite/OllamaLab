//
//  SettingsSectionView.swift
//  OllamaLab
//
//  Created by Zsombor Szenyan on 19/08/2024.
//

import SwiftUI

struct SettingsSectionView<SectionContent: View>: View {
    @ViewBuilder let SectionContent: SectionContent
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SettingsSectionView {
        SettingView(systemImage: "globe", setting: "isSomething") {
            Text("hi")
        }
    }
}
