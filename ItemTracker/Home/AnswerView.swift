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
    AnswerView(answer: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
}
