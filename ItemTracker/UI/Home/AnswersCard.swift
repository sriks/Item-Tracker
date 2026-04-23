//
//  AnswersCard.swift
//  ItemTracker
//

import SwiftUI

// MARK: - AnswersCard

/// A self-contained card that displays a query and its AI-generated answer.
/// Compose into any screen by providing `question`, `answer`, and optional room `tags`.
struct AnswersCard: View {
    let question: String
    let answer: String
    var tags: [(name: String, token: ColorToken)] = []

    @Environment(\.appTheme) private var theme: any AppTheme
    @Environment(\.constants) private var constants: DesignConstants

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            questionBand
            divider
            answerBand
        }
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: constants.cornerRadiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: constants.cornerRadiusCard)
                .strokeBorder(theme.hairline, lineWidth: constants.borderWidth)
        )
    }

    // MARK: Private bands

    private var questionBand: some View {
        HStack(spacing: constants.medium) {
            Image(systemName: "magnifyingglass")
                .font(.callout)
                .foregroundStyle(theme.secondaryText)

            Text(question)
                .font(.subheadline.italic())
                .foregroundStyle(theme.secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.hairline)
            .frame(height: constants.borderWidth)
    }

    private var answerBand: some View {
        VStack(alignment: .leading, spacing: constants.xMedium) {
            Text(answer)
                .font(.system(size: 19))
                .foregroundStyle(theme.primaryText)

            if !tags.isEmpty {
                HStack(spacing: constants.medium) {
                    ForEach(tags, id: \.name) { tag in
                        RoomTagPill(name: tag.name, token: tag.token)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// MARK: - RoomTagPill

private struct RoomTagPill: View {
    let name: String
    let token: ColorToken

    @Environment(\.constants) private var constants: DesignConstants

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(token.color)
                .frame(width: 8, height: 8)

            Text(name)
                .font(.footnote.weight(.medium))
                .foregroundStyle(token.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(token.color.opacity(0.15))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(token.color.opacity(0.42), lineWidth: constants.borderWidth)
        )
    }
}

// MARK: - Previews

#Preview("Dark") {
    AnswersCard(
        question: "Where are the macbook chargers?",
        answer: "Macbook chargers are stored in the library, 3rd drawer from the top.",
        tags: [
            (name: "Library", token: .blue),
            (name: "Storage", token: .amber),
        ]
    )
    .appTheme(MonochromeTheme(scheme: .dark))
    .preferredColorScheme(.dark)
    .padding()
}

#Preview("Light") {
    AnswersCard(
        question: "Where are the macbook chargers?",
        answer: "Macbook chargers are stored in the library, 3rd drawer from the top.",
        tags: [
            (name: "Library", token: .blue),
        ]
    )
    .appTheme(MonochromeTheme(scheme: .light))
    .preferredColorScheme(.light)
    .padding()
}

#Preview("No tags") {
    AnswersCard(
        question: "Where did I put the scissors?",
        answer: "The scissors are on the kitchen counter, next to the coffee maker."
    )
    .appTheme(MonochromeTheme(scheme: .dark))
    .preferredColorScheme(.dark)
    .padding()
}
