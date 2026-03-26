//
//  ItemsView.swift
//  ItemTracker
//
//  Created by Srikanth on 8/3/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import SwiftUI

/// Displays the full list of saved items under the Items tab.
///
/// Renders a `List` of items sourced from `ItemsViewModel`. Shows an empty state
/// when no items have been saved yet. All formatting is delegated to the view model —
/// the view binds directly to pre-formatted strings from `ItemDisplayModel`.
struct ItemsView: View {
    var viewModel: ItemsViewModel
    @State private var showAddItem = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "tray",
                        description: Text("Saved items will appear here.")
                    )
                } else {
                    List(viewModel.items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.text)
                            Text(item.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemSheet(viewModel: viewModel)
            }
        }
    }
}

private struct AddItemSheet: View {
    var viewModel: ItemsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                TextEditor(text: $text)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(isSaving)
                Spacer()
            }
            .padding()
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        isSaving = true
                        Task {
                            try? await viewModel.addItem(text: text.trimmingCharacters(in: .whitespacesAndNewlines))
                            dismiss()
                        }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
