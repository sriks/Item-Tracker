//
//  AnswerView.swift
//  ItemTracker
//
//  Created by Srikanth on 15/1/2026.
//

import SwiftUI

struct AnswerView: View {
    var answer: String

    var body: some View {
        ZStack(alignment: .leading) {
            AnimatedGlowEffect()

            ScrollView {
                // Answers stack view
                VStack(alignment: .leading, spacing: 12) {
                    Text("Answer")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(answer)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding()
            }
        }
        .glassEffect(.regular.tint(.white.opacity(0.4)), in: .rect(cornerRadius: 16))
        .padding()
    }
}

#Preview {
    AnswerView(answer: "Lorem Ipsum is simply dummy text of the printing industry.")
}
