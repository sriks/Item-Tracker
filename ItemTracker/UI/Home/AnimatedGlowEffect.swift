//
//  AnimatedGlowEffect.swift
//  ItemTracker
//
//  Created by Srikanth on 13/1/2026.
//

import SwiftUI

// MARK: - Reusable Animated Glow Effect

struct AnimatedGlowEffect: View {
    @State private var animateGradient = true
    let cornerRadius: CGFloat
    let maskRadius: CGFloat

    init(cornerRadius: CGFloat = 16, maskRadius: CGFloat = 120) {
        self.cornerRadius = cornerRadius
        self.maskRadius = maskRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.15),
                        Color.pink.opacity(0.15),
                        Color.orange.opacity(0.15),
                        Color.yellow.opacity(0.15),
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomTrailing,
                    endPoint: animateGradient ? .bottomTrailing : .topLeading
                )
            )
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
            .shadow(
                color: Color.blue.opacity(0.3),
                radius: 8,
                x: 0,
                y: 0
            )
            .shadow(
                color: Color.purple.opacity(0.3),
                radius: 12,
                x: 0,
                y: 0
            )
            .shadow(
                color: Color.pink.opacity(0.2),
                radius: 16,
                x: 0,
                y: 0
            )
            .mask(
                // Radial gradient mask for faded edges
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: 0.0),
                        .init(color: .black, location: 0.7),
                        .init(color: .clear, location: 1.0),
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: maskRadius
                )
            )
            .onAppear {
                animateGradient = true
            }
    }
}
