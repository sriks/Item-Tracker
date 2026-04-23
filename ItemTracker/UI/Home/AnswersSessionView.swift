//
//  AnswersSessionView.swift
//  ItemTracker
//

import SwiftUI

// MARK: - AnswersSessionView

/// Floating inline surface that sits directly above the search bar and accumulates answer cards.
/// Expands upward as answers arrive, capped at 70% of available screen height.
/// Dismissed by calling `session.reset()` which clears answers and collapses the surface.
struct AnswersSessionView: View {
    @Bindable var session: AnswersSessionViewModel
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants

    private var maxSurfaceHeight: CGFloat {
        UIScreen.main.bounds.height * 0.70
    }

    @State private var contentHeight: CGFloat = 0
    private var surfaceHeight: CGFloat {
        min(contentHeight, maxSurfaceHeight)
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: constants.itemGap) {
                    ForEach(session.answers) { answer in
                        AnswersCard(
                            question: answer.question,
                            answer: answer.result.displayText
                        )
                        .id(answer.id)
                    }
                }
                .padding(.horizontal, constants.horizontalPadding)
                .padding(.bottom, constants.medium)
                .padding(.top, constants.xLarge)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                    contentHeight = $0
                }
            }
            .frame(height: surfaceHeight)
            .onChange(of: session.answers.count) {
                if let last = session.answers.last {
                    withAnimation { scrollProxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
        .background(.regularMaterial)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: constants.cornerRadiusCard,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: constants.cornerRadiusCard
            )
        )
        .overlay(alignment: .topTrailing) {
            dismissButton
                .padding(.trailing, constants.horizontalPadding)
                .padding(.top, constants.small)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: Private

    private var dismissButton: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                session.reset()
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(theme.secondaryText)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AnswerResult display

extension AnswersSessionViewModel.AnswerResult {
    var displayText: String {
        switch self {
        case let .success(text): text
        case let .error(message): message
        }
    }
}

// MARK: - Previews

#Preview("Dark — multiple answers") {
    let session = AnswersSessionViewModel(brain: (try! DependencyContainer.preview()).itemFinder)
    session.seed([
        .init(
            question: "Where are the macbook chargers?",
            result: .success("Macbook chargers are stored in the library, 3rd drawer from the top.")
        ),
        .init(
            question: "Where did I put the scissors?",
            result: .success("The scissors are on the kitchen counter, next to the coffee maker.")
        ),
        .init(
            question: "What's in the storage room?",
            result: .success("Toilet rolls (2nd row), cleaning supplies, spare lightbulbs in the top box.")
        ),
    ])
    return VStack(spacing: 0) {
        Spacer()
        AnswersSessionView(session: session)
            .appTheme(MonochromeTheme(scheme: .dark))
    }
    .preferredColorScheme(.dark)
    .background(Color(white: 0.05))
}

#Preview("Light — single answer") {
    let session = AnswersSessionViewModel(brain: (try! DependencyContainer.preview()).itemFinder)
    session.seed([
        .init(
            question: "Where are the macbook chargers?",
            result: .success("Macbook chargers are stored in the library, 3rd drawer from the top.")
        ),
    ])
    return VStack(spacing: 0) {
        Spacer()
        AnswersSessionView(session: session)
            .appTheme(MonochromeTheme(scheme: .light))
    }
    .preferredColorScheme(.light)
}
