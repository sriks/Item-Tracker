//
//  HomeView.swift
//  ItemTracker
//
//  Created by Srikanth on 13/1/2026.
//

import SwiftUI

// MARK: - Home View
struct HomeView: View {
    @Bindable var queryViewModel: QueryViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                // Empty now
            }
            .safeAreaInset(edge: .bottom) {
                // MARK: Query view
                VStack {
                    
                    if let answer = queryViewModel.answer {
                        AnswerView(answer: answer)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack {
                        // Text field
                        TextField("Where are chargers?", text: $queryViewModel.query)
                            .textFieldStyle(.plain)
                            .keyboardType(.default)
                            .submitLabel(queryViewModel.query.isEmpty ? .done : .search)
                            .onSubmit {
                                queryViewModel.runQuery()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .frame(alignment: .bottom)
            }
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.preview()
    HomeView(queryViewModel: QueryViewModel(brain: dependencies.itemFinder))
}
