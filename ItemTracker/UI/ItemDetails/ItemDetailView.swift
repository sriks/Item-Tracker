//
//  ItemDetailView.swift
//  ItemTracker
//
//  Created by Srikanth on 26/3/2026.
//  Copyright © 2026 Dreamcode Pty Ltd. All rights reserved.
//

import SwiftUI

/// Displays and allows editing or deletion of a single saved item.
///
/// Pushed onto the navigation stack when the user taps a row in `ItemsView`.
/// Shows a `TextEditor` for in-place editing with a Save button that activates
/// only when unsaved changes exist. A Delete button at the bottom triggers a
/// confirmation alert before removing the item.
struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ItemDetailViewModel
    @State private var showDeleteConfirmation = false
    @State private var isBusy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $viewModel.editedText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isBusy)

            Text(viewModel.item.formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            Spacer()

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Item", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isBusy)
        }
        .padding()
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isBusy {
                    ProgressView()
                } else {
                    Button("Save") {
                        isBusy = true
                        Task {
                            try? await viewModel.save()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
        }
        .alert("Delete Item?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                isBusy = true
                Task {
                    try? await viewModel.delete()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This item will be permanently deleted.")
        }
    }
}
