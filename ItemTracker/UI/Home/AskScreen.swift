//
//  AskScreen.swift
//  ItemTracker
//

import SwiftUI

// MARK: - Ask Screen

struct AskScreen: View {
    @Bindable var queryViewModel: QueryViewModel
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppHeaderView()

                Spacer().frame(height: constants.sectionSpacing)

                // Large title + subtitle
                VStack(alignment: .leading, spacing: constants.small) {
                    Text(.whereIsIt)
                        .font(.largeTitle.bold())
                        .tracking(-1)
                        .foregroundStyle(theme.primaryText)

                    Text(.askInPlainEnglish)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }
            }
            .padding(.horizontal, constants.horizontalPadding)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                QueryView(queryViewModel: queryViewModel)
            }.padding()
        }
    }
}

// MARK: - App Header

private struct AppHeaderView: View {
    @Environment(\.appTheme) private var theme: any AppTheme

    var body: some View {
        HStack(spacing: 10) {
            // Logo
            ZStack {
                Image(systemName: "magnifyingglass")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(theme.primaryText)
            }

            Text(.itemTracker)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.primaryText)

            Spacer()
        }
    }
}

// MARK: - QueryView

private struct QueryView: View {
    @Bindable var queryViewModel: QueryViewModel
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants
    private let isMicEnabled: Bool = false
    
    var body: some View {
        // Text field
        TextField(.askWhereSomethingIs,
                  text: $queryViewModel.query)
            .textFieldStyle(.plain)
            .keyboardType(.default)
            .submitLabel(queryViewModel.query.isEmpty ? .done : .search)
            .onSubmit {
                queryViewModel.runQuery()
            }
            .safeAreaInset(edge: .leading) {
                // TODO: Animate flowing circle when query is in progress.
                Image(systemName: "magnifyingglass")
                    .font(.callout)
                    .foregroundStyle(theme.secondaryText)
            }
            .safeAreaInset(edge: .trailing) {
                // For speak with siri or voice query.
                if isMicEnabled {
                    ZStack {
                        Circle()
                            .fill(theme.micButtonBackground)
                            .frame(width: constants.large, height: constants.large)

                        Image(systemName: "mic.fill")
                            .font(.footnote)
                            .foregroundStyle(theme.secondaryText)
                    }
                } else {
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(theme.searchBarBorder,
                                  lineWidth: constants.borderWidth)
            )
    }
}

// MARK: - Previews

#Preview("Dark") {
    AskScreen(queryViewModel: QueryViewModel(brain: (try! DependencyContainer.preview()).itemFinder))
        .appTheme(MonochromeTheme(scheme: .dark))
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    AskScreen(queryViewModel: QueryViewModel(brain: (try! DependencyContainer.preview()).itemFinder))
        .appTheme(MonochromeTheme(scheme: .light))
        .preferredColorScheme(.light)
}
