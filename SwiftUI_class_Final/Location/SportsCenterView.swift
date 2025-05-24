import SwiftUI

struct SportsCenterView: View {
    @EnvironmentObject var game: GameState

    /// The value currently shown on each die (updates while rolling)
    @State private var displayPlayer = 1
    @State private var displayOpponent = 1

    /// The final rolled values (used for result logic & alert)
    @State private var finalPlayerRoll: Int?
    @State private var finalOpponentRoll: Int?

    /// Control flags
    @State private var isRolling = false
    @State private var showResult = false

    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(colors: [.blue.opacity(0.2), .cyan.opacity(0.1)],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 標題與說明
                VStack(spacing: 8) {
                    Text("新體")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("運動好去處")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // 說明或互動
                if game.inventory.contains(.squashRacket) && !game.inventory.contains(.mcdCoupon) {
                    VStack(spacing: 16) {
                        Text("到了壁球室，來比一場賽吧！\n（如果骰得比對手大，代表回擊成功！）")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            rollDice()
                        } label: {
                            HStack {
                                Image(systemName: "die.face.5.fill")
                                Text(isRolling ? "擲骰中…" : "接受挑戰 · 擲骰子")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(colors: [.indigo, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .foregroundStyle(.white)
                            .shadow(radius: 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isRolling) // 防止多次點擊

                        // 骰子畫面
                        HStack(spacing: 40) {
                            DiceView(value: displayPlayer, label: "你")
                            DiceView(value: displayOpponent, label: "對手")
                        }
                        .padding(.top)
                    }
                } else {
                    // 沒有觸發條件時的靜態描述
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("滿滿的運動氣息瀰漫在空氣中。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .alert("比賽結果", isPresented: $showResult) {
            Button("好的") {}
        } message: {
            if let p = finalPlayerRoll, let o = finalOpponentRoll {
                if p > o {
                    Text("你擲出 \(p)，對手 \(o)。獲勝！得到麥當勞優惠券。")
                } else if p == o {
                    Text("你擲出 \(p)，對手 \(o)。平手，再接再厲！")
                } else {
                    Text("你擲出 \(p)，對手 \(o)。可惜，敗北。")
                }
            }
        }
    }

    /// 擲骰並播放滾動動畫
    private func rollDice() {
        guard !isRolling else { return }
        isRolling = true

        finalPlayerRoll = nil
        finalOpponentRoll = nil

        let totalIterations = 20 // 動畫換臉次數
        var currentIteration = 0

        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            // 每次刷新顯示亂數點數，造成轉動感覺
            displayPlayer = Int.random(in: 1...6)
            displayOpponent = Int.random(in: 1...6)
            currentIteration += 1

            if currentIteration >= totalIterations {
                timer.invalidate()

                // 決定最終點數
                let p = Int.random(in: 1...6)
                let o = Int.random(in: 1...6)
                finalPlayerRoll = p
                finalOpponentRoll = o
                displayPlayer = p
                displayOpponent = o

                // 奬勵判斷
                if p > o {
                    game.inventory.insert(.mcdCoupon)
                }

                // 稍作停頓後顯示結果
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showResult = true
                    isRolling = false
                }
            }
        }
    }
}

// MARK: - DiceView

struct DiceView: View {
    let value: Int
    let label: String

    var body: some View {
        VStack {
            Image(systemName: "die.face.\(value).fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundStyle(.orange)
                .animation(.easeInOut(duration: 0.08), value: value) // 小動畫漸變

            Text(label)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}
