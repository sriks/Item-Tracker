//
//  SettingsView.swift
//  ItemTracker
//

import SwiftUI

struct SettingsView: View {
    let promptStore: PromptStorable

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        CustomPromptView(viewModel: CustomPromptViewModel(store: promptStore))
                    } label: {
                        Label("Customise Prompt", systemImage: "text.bubble.fill")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
