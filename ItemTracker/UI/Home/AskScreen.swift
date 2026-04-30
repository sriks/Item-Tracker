//
//  AskScreen.swift
//  ItemTracker
//

import SwiftUI

// MARK: - Ask Screen

struct AskScreen: View {
    @Bindable var session: AnswersSessionViewModel
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants

    /// Tracks the scroll view's rendered height, which shrinks when the keyboard appears.
    @State private var scrollViewHeight: CGFloat = 0
    @FocusState private var isQueryFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AppHeaderView()

                Spacer().frame(height: constants.sectionSpacing)

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
            .onTapGesture {
                isQueryFieldFocused = false
                session.reset()
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
            scrollViewHeight = $0
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                if session.isPresented {
                    AnswersSessionView(session: session, maxHeight: scrollViewHeight * 0.70)
                }
                QueryView(session: session, isFocused: $isQueryFieldFocused)
                    .padding()
            }
            .animation(.spring(duration: 0.35), value: session.isPresented)
        }
    }
}

// MARK: - App Header

private struct AppHeaderView: View {
    @Environment(\.appTheme) private var theme: any AppTheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.callout.weight(.medium))
                .foregroundStyle(theme.primaryText)

            Text(.itemTracker)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.primaryText)

            Spacer()
        }
    }
}

// MARK: - QueryView

private struct QueryView: View {
    @Bindable var session: AnswersSessionViewModel
    @FocusState.Binding var isFocused: Bool
    @State private var query = ""
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants
    private let isMicEnabled = false

    var body: some View {
        TextField(
            session.isPresented ? .askAnotherQuestion : .askWhereSomethingIs,
            text: $query
        )
        .focused($isFocused)
        .textFieldStyle(.plain)
        .submitLabel(query.isEmpty ? .done : .search)
        .disabled(session.isQuerying)
        .onSubmit {
            let captured = query
            query = ""
            Task { await session.ask(captured) }
        }
        .safeAreaInset(edge: .leading) {
            Image(systemName: session.isQuerying ? "circle.dotted" : "magnifyingglass")
                .font(.callout)
                .foregroundStyle(theme.secondaryText)
                .symbolEffect(.pulse, isActive: session.isQuerying)
        }
        .safeAreaInset(edge: .trailing) {
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
                .strokeBorder(theme.searchBarBorder, lineWidth: constants.borderWidth)
        )
    }
}

// MARK: - Previews

#Preview("Dark") {
    AskScreen(session: AnswersSessionViewModel(brain: (try! DependencyContainer.preview()).itemFinder))
        .appTheme(MonochromeTheme(scheme: .dark))
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    AskScreen(session: AnswersSessionViewModel(brain: (try! DependencyContainer.preview()).itemFinder))
        .appTheme(MonochromeTheme(scheme: .light))
        .preferredColorScheme(.light)
}
