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
        }
    }
}
