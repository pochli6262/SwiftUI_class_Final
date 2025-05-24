//
//  LakePavilionView.swift
//  SwiftUI_class_Final
//
//  Created by 廖柏鈞 on 2025/5/23.
//
import SwiftUI

// MARK: - Lake Pavilion (美化版)

struct LakePavilionView: View {
    @EnvironmentObject var game: GameState
    @State private var showSummon = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal.opacity(0.2), .blue.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("醉月湖心亭")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("湖中靜謐之地，啟動魔法的關鍵")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if game.hasAllTokens() && !game.summonCompleted {
                    Button {
                        game.summonCompleted = true
                        showSummon = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("啟動魔法陣")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                        )
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else if game.summonCompleted {
                    VStack(spacing: 16) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        Text("魔法陣已經啟動！新生教學館閃耀著光芒。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "water.waves")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("湖面波光粼粼，湖心亭靜默佇立……")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .alert("魔法陣完成", isPresented: $showSummon) {
            Button("前往新生教學館") {}
        } message: {
            Text("五道光束連結：德田館→新體→活大→天文數學館→傅鐘→湖心亭！新生教學館亮起了！")
        }
    }
}
