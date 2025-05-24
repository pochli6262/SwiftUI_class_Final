// MARK: - Fu Bell (美化版)

import SwiftUI

struct FuBellView: View {
    @EnvironmentObject var game: GameState
    @State private var showQuiz = false
    @State private var showResult = false
    @State private var correct = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.gray.opacity(0.2), .blue.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("傅鐘")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("台大最神秘的鐘聲傳說")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if game.inventory.contains(.fuBellClue) && !game.inventory.contains(.fuBellToken) {
                    VStack(spacing: 16) {
                        Text("你感受到鐘聲的回響，有個聲音對你耳語……")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            showQuiz = true
                        } label: {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("接受傅鐘咒靈的考驗")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.blue, .gray], startPoint: .leading, endPoint: .trailing))
                            )
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else if game.inventory.contains(.fuBellToken) {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("傅鐘咒物已入手，時間凝結在鐘聲之中……")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("傳說聽見21聲鐘響就會被詛咒……")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .confirmationDialog("傅鐘咒靈考驗：傅鐘每節上下課敲幾下？", isPresented: $showQuiz, titleVisibility: .visible) {
            Button("A. 21") { answer(true) }
            Button("B. 24") { answer(false) }
            Button("C. 27") { answer(false) }
        }
        .alert(correct ? "答對了！" : "答錯了", isPresented: $showResult) {
            Button("好的") {}
        } message: {
            if correct {
                Text("傅鐘咒物到手！五個信物已集結，去湖心亭啟動魔法陣吧！")
            } else {
                Text("這學期逃不過21魔咒了……")
            }
        }
    }

    private func answer(_ isCorrect: Bool) {
        correct = isCorrect
        if isCorrect {
            game.inventory.insert(.fuBellToken)
        }
        showResult = true
    }
}

