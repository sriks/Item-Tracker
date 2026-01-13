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
            VStack {
                Text("Query your items here")
                    .foregroundStyle(.secondary)
                
                ZStack {
                    // Background gradient with faded edges
                    AnimatedGlowEffect()
                    
                    // Text field
                    TextField("Search", text: $queryViewModel.query)
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
                .padding()
                
                if let answer = queryViewModel.answer {
                    Text(answer)
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    let dependencies = DependencyContainer.preview()
    HomeView(queryViewModel: QueryViewModel(brain: dependencies.itemFinder))
}
