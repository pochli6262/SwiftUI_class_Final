//
//  SuccessContentView.swift
//  SwiftUI_class_Final
//
//  Created by 廖柏鈞 on 2025/5/23.
//
import SwiftUI

// Extract complex content into separate views to fix type-checking issues
struct SuccessContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("恭喜通過所有試煉！")
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            Text("你成功集齊所有信物，完成了魔法陣的啟動。")
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .padding(.vertical)
            
            VStack(spacing: 16) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
                    .padding()
                    .background(Circle().fill(.blue.opacity(0.2)))
                
                Text("新生入學證明")
                    .font(.title3.bold())
                
                Text("持有者已完成臺大新生考驗，特頒此證")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 5)
            )
            .padding(.horizontal)
            
            Text("歡迎成為臺大的一份子！")
                .font(.headline)
                .padding(.top)
        }
    }
}

struct WaitingContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("夢開始的地方……")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text("這座建築物看起來普通，但卻散發著神秘的能量。你感覺這裡與你的旅程息息相關，但現在似乎還不是進入的時機。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary.opacity(0.8))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
        }
    }
}

// Simple confetti effect
struct ConfettiView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let count = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                ConfettiPiece(color: colors[i % colors.count])
            }
        }
    }
}

struct ConfettiPiece: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation = Double.random(in: 0...360)
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .position(x: position.x, y: position.y)
            .rotationEffect(.degrees(rotation))
            .opacity(0.7)
            .onAppear {
                // Randomize position
                position = CGPoint(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width-50),
                    y: CGFloat.random(in: -100...0)
                )
                
                // Animate falling
                withAnimation(.easeOut(duration: Double.random(in: 2...5))) {
                    position.y += UIScreen.main.bounds.height + 100
                    rotation += Double.random(in: 180...540)
                }
            }
    }
}
