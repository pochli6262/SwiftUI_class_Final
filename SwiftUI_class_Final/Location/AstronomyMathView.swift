// MARK: - Astronomy Math (美化版)

import SwiftUI

struct AstronomyMathView: View {
    @EnvironmentObject var game: GameState
    @State private var answer = ""
    @State private var showWrong = false
    @State private var showRight = false

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(colors: [.purple.opacity(0.2), .indigo.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 標題
                VStack(spacing: 8) {
                    Text("天文數學館")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("台灣數學的終極殿堂")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // 劇情與輸入
                if game.inventory.contains(.decryptionKey) && !game.inventory.contains(.fuBellClue) {
                    VStack(spacing: 16) {
                        Text("老教授：有了密鑰 d=3，我可以破譯密文 IXEHOO")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        TextField("請輸入明文", text: $answer)
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)

                        Button {
                            validate()
                        } label: {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("提交")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                            )
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("寂靜的長廊回響著你的腳步……")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .alert("答案錯誤", isPresented: $showWrong) {
            Button("再試一次") {}
        }
        .alert("獲得提示", isPresented: $showRight) {
            Button("好的") {}
        } message: {
            Text("你得到神秘提示：FUBELL。這是在說哪裡？")
        }
    }

    private func validate() {
        if answer.uppercased() == "FUBELL" {
            game.inventory.insert(.fuBellClue)
            showRight = true
        } else {
            showWrong = true
        }
    }
}
