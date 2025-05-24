// MARK: - Activity Center (美化版)

import SwiftUI

struct ActivityCenterView: View {
    @EnvironmentObject var game: GameState
    @State private var showChoice = false
    @State private var showThank = false

    var body: some View {
        ZStack {
            // 背景色系
            LinearGradient(colors: [.orange.opacity(0.2), .yellow.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView{
                VStack(spacing: 24) {
                    // 標題
                    VStack(spacing: 8) {
                        Image("活大麥當勞")
                            .resizable()
                            .frame(width: 300, height:300)
                        Text("活大")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        
                        Text("餐飲聚集地")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 狀態呈現與互動
                    if game.inventory.contains(.mcdCoupon) && !game.inventory.contains(.decryptionKey) {
                        VStack(spacing: 16) {
                            Text("你拿著麥當當優惠券，考慮是否排隊。")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button {
                                showChoice = true
                            } label: {
                                HStack {
                                    Image(systemName: "bag.fill")
                                    Text("排隊買麥當勞")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                )
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            
                            Text("中午人潮洶湧，看來要排很久……")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .confirmationDialog("老人請求你帶他去天文數學館", isPresented: $showChoice, titleVisibility: .visible) {
            Button("帶他去") {
                game.inventory.insert(.decryptionKey)
                showThank = true
            }
            Button("拒絕", role: .destructive) {}
        }
        .alert("獲得密鑰", isPresented: $showThank) {
            Button("好的") {}
        } message: {
            Text("你獲得了密鑰 d=3。該去天文數學館了！")
        }
    }
}
