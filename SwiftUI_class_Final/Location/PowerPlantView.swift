//
//  PowerPlantView.swift
//  SwiftUI_class_Final
//
//  Created by 廖柏鈞 on 2025/5/23.
//
import SwiftUI

// MARK: - Power Plant

struct PowerPlantView: View {
    @EnvironmentObject var game: GameState
    @State private var code = ""
    @State private var showGate = false
    @State private var showSuccess = false
    @State private var showHint = false
    @State private var attemptCount = 0
    @State private var isShaking = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header image
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                        )
                    
                    // Title
                    Text("德田館")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                    
                    Text("電神聚集之殿堂")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    
                    
                    // Description
                    Text("空氣中充滿了電子元件的氣息，走廊上不時有穿著印有程式碼的T恤的學生匆匆走過。牆上掛滿了電路板和各種計算機科學先驅的照片，彷彿在述說著數位時代的起源與演變。")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                    
                    Image("德田館")
                        .resizable()
                        .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    if game.inventory.contains(.libraryNote) && !game.inventory.contains(.squashRacket) {
                        VStack(spacing: 20) {
                            Text("你手持紙條，感受到前方高壓電場散發出的微妙能量波動...")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    showGate = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "lock.shield")
                                    Text("進入高壓電場")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(radius: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                                .padding()
                            
                            Text("一群電神正在專注地編寫代碼和維護系統，確保整個台大校園的網絡和電力系統正常運作。他們對你的到來似乎毫不在意，全神貫注於他們的工作之中。")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
        }
        .sheet(isPresented: $showGate) {
            ZStack {
                Color.black.opacity(0.9).ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("🔐 高壓電場安全系統 🔐")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Text("請輸入四位數字密碼以解鎖入口")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("系統提示：")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        Text("將以下二進制數字轉換為十進制：")
                            .foregroundStyle(.green.opacity(0.8))
                        
                        Group {
                            Text("1001 = ?")
                            Text("101 = ?")
                            Text("10 = ?")
                            Text("111 = ?")
                        }
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.green)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    
                    TextField("", text: $code)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        .foregroundStyle(.green)
                        .frame(width: 200)
                        .modifier(ShakeEffect(animatableData: isShaking ? 5 : 0))
                    
                    HStack(spacing: 20) {
                        Button("提示") {
                            showHint = true
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.6))
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        
                        Button("確認") {
                            if code == "9527" {
                                game.inventory.insert(.squashRacket)
                                showSuccess = true
                                showGate = false
                            } else {
                                attemptCount += 1
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.2)) {
                                    isShaking = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isShaking = false
                                }
                                
                                if attemptCount >= 3 {
                                    showHint = true
                                }
                                code = ""
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .alert("解碼提示", isPresented: $showHint) {
                    Button("了解") {}
                } message: {
                    Text("二進制轉十進制:\n1001 = 9\n101 = 5\n10 = 2\n111 = 7\n\n將這四個數字按順序連接起來...")
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("神秘獎勵", isPresented: $showSuccess) {
            Button("領取") {}
        } message: {
            Text("穿過高壓電場後，電神首領微笑著向你走來：\n\n「你的二進制轉換能力令人印象深刻！作為獎勵，這支特製壁球拍現在是你的了。校園中有個地方專為運動愛好者準備，或許你該去那裡看看？」\n\n獲得道具：⚡壁球拍⚡")
        }
    }
}

// Add this modifier for shake effect
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 2), y: 0))
    }
}
