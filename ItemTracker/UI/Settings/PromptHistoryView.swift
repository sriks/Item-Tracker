//
//  PromptHistoryView.swift
//  ItemTracker
//

import SwiftUI

/// Sheet that lists saved prompts. Tapping a row calls `onSelect` and dismisses,
/// letting `CustomPromptView` prefill the editor with the chosen prompt.
struct PromptHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    let history: [String]
    let onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    ContentUnavailableView(
                        "No saved prompts yet",
                        systemImage: "text.bubble"
                    )
                } else {
                    List(history, id: \.self) { prompt in
                        Button {
                            onSelect(prompt)
                            dismiss()
                        } label: {
                            Text(prompt)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Prompt History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
