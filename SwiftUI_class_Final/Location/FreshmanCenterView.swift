//
//  FreshmanCenterView.swift
//  SwiftUI_class_Final
//
//  Created by 廖柏鈞 on 2025/5/23.
//
import SwiftUI

// MARK: - Freshman Center

struct FreshmanCenterView: View {
    @EnvironmentObject var game: GameState
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.yellow.opacity(0.2), .orange.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Image(systemName: game.summonCompleted && game.hasAllTokens() ? "checkmark.seal.fill" : "building.columns")
                    .font(.system(size: 70))
                    .foregroundStyle(game.summonCompleted && game.hasAllTokens() ? .yellow : .gray)
                    .padding()
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 8)
                    )
                
                // Title
                Text("新生教學館")
                    .font(.largeTitle.bold())
                
                // Content - Split into dedicated subviews to avoid compiler issues
                if game.summonCompleted && game.hasAllTokens() {
                    SuccessContentView()
                        .transition(.scale.combined(with: .opacity))
                } else {
                    WaitingContentView()
                        .transition(.opacity)
                }
            }
            .padding()
            
            // Confetti overlay
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            if game.summonCompleted && game.hasAllTokens() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showConfetti = true
                    }
                }
            }
        }
    }
}
