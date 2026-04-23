//
//  HomeView.swift
//  ItemTracker
//
//  Created by Srikanth on 13/1/2026.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @Bindable var session: AnswersSessionViewModel

    var body: some View {
        AskScreen(session: session)
    }
}

#Preview {
    let dependencies = try! DependencyContainer.preview()
    HomeView(session: AnswersSessionViewModel(brain: dependencies.itemFinder))
}
