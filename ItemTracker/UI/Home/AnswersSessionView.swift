//
//  AnswersSessionView.swift
//  ItemTracker
//

import SwiftUI

// MARK: - AnswersSessionView

/// Floating inline surface that sits directly above the search bar and shows the current answer.
/// Sizes to fit its content, capped at `maxHeight` (caller derives this from the available
/// content area so it naturally accounts for keyboard height changes).
/// Dismissed by calling `session.reset()` which clears the answer and collapses the surface.
struct AnswersSessionView: View {
    @Bindable var session: AnswersSessionViewModel
    /// Maximum height the surface may grow to. Passed in by `AskScreen` which measures
    /// the scroll view height — shrinks automatically when the keyboard appears.
    var maxHeight: CGFloat
    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants

    @State private var contentHeight: CGFloat = 0
    private var surfaceHeight: CGFloat {
        min(contentHeight, maxHeight)
    }

    var body: some View {
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
        .background(.clear)
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
                .padding(.top, constants.medium)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

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

#Preview("Dark") {
    VStack(spacing: 0) {
        Spacer()
        AnswersSessionView(session: .preview(answers: 1), maxHeight: 500)
            .appTheme(MonochromeTheme(scheme: .dark))
    }
    .preferredColorScheme(.dark)
    .background(Color(white: 0.05))
}

#Preview("Light") {
    VStack(spacing: 0) {
        Spacer()
        AnswersSessionView(session: .preview(answers: 1), maxHeight: 500)
            .appTheme(MonochromeTheme(scheme: .light))
    }
    .preferredColorScheme(.light)
}
