//
//  CustomPromptView.swift
//  ItemTracker
//

import SwiftUI

struct CustomPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CustomPromptViewModel
    @State private var showHistory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Edit the instructions used when answering item location queries.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            TextEditor(text: $viewModel.editingPrompt)
                .font(.body)
                .padding(8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
        }
        .navigationTitle("Customise Prompt")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Use This Prompt") {
                    viewModel.savePrompt()
                    dismiss()
                }
                .bold()
                .disabled(!viewModel.hasChanges)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("View History") {
                    showHistory = true
                }
                .disabled(viewModel.promptHistory.isEmpty)
            }
        }
        .sheet(isPresented: $showHistory) {
            PromptHistoryView(history: viewModel.promptHistory) { selected in
                viewModel.apply(historyPrompt: selected)
            }
        }
    }
}
