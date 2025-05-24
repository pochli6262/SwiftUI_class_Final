//
//  LibraryView.swift
//  SwiftUI_class_Final
//
//  Created by 廖柏鈞 on 2025/5/23.
//
import SwiftUI

// MARK: - Library

struct LibraryView: View {
    @EnvironmentObject var game: GameState
    @State private var showAlert = false
    @State private var selectedFloor: Int? = nil
    @State private var floorDescription = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.indigo.opacity(0.3), .blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                Spacer()
                VStack(spacing: 20) {
                    // Header image and title
                    LibraryHeaderView()
                    
                    
                    // Floor details (if a floor is selected)
                    if let floor = selectedFloor {
                        Image("library_\(floor)")
                            .resizable()
                            .frame(width: 300, height: 300)
                        
                        LibraryFloorDetailView(floor: floor, description: floorDescription)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Floor selection
                    LibraryFloorSelectorView(
                        selectedFloor: $selectedFloor,
                        floorDescription: $floorDescription,
                        onFloorSelected: { floor in
                            if floor == 3 && !game.inventory.contains(.libraryNote) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showAlert = true
                                }
                            }
                        }
                    )
                    
                    
                }
                .padding(.bottom, 30)
            }
        }
        .alert("神秘紙條", isPresented: $showAlert) {
            Button("小心收好") { 
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    _ = game.inventory.insert(.libraryNote)
                }
            }
        } message: {
            Text("當你專注閱讀書架上的古籍時，一張泛黃的紙條從書頁間輕輕滑落。你拾起紙條，上面潦草地寫著：\n\n「若尋求真知，前往電神聖殿—德田館。唯有掌握二進制之力，方可一窺究竟。」\n\n這顯然是通往下一步的關鍵線索！")
        }
    }
}

// Split the Library View into smaller components
struct LibraryHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Header image
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 60))
                .foregroundStyle(.indigo)
                .padding()
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 5)
                )
            
            // Title
            Text("臺大圖書館")
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            // Description
            Text("這座擁有百年歷史的知識殿堂，珍藏著無數珍貴典籍和學術資源。每一層樓都蘊藏著不同的秘密，而你的探索才剛剛開始。")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.secondary)
        }
    }
}

struct LibraryFloorSelectorView: View {
    @Binding var selectedFloor: Int?
    @Binding var floorDescription: String
    var onFloorSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("選擇要探索的樓層")
                .font(.headline)
                .padding(.top)
            
            ForEach([3, 2, 1, 4], id: \.self) { floor in
                Button {
                    selectedFloor = floor
                    floorDescription = getFloorDescription(floor)
                    onFloorSelected(floor)
                } label: {
                    HStack {
                        Image(systemName: getFloorIcon(floor))
                            .font(.title2)
                        Text(floor == 4 ? "地下室" : "\(floor)樓")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedFloor == floor ? Color.blue.opacity(0.2) : Color.white.opacity(0.8))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedFloor == floor ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
    
    private func getFloorIcon(_ floor: Int) -> String {
        switch floor {
        case 3: return "3.square.fill"
        case 2: return "2.square.fill"
        case 1: return "1.square.fill"
        case 4: return "arrow.down.square.fill"
        default: return "questionmark.square.fill"
        }
    }
    
    private func getFloorDescription(_ floor: Int) -> String {
        switch floor {
        case 3:
            return "三樓的古籍特藏區域燈光柔和，空氣中彌漫著淡淡的紙張氣息。書架排列得有些凌亂，似乎有人曾在此匆忙搜尋過什麼。角落裡的一個書架特別引人注目，那裡的書籍看起來格外古老。"
        case 2:
            return "二樓是各類學科的專業藏書，井然有序地排列在高大的書架上。幾名學生正在安靜地閱讀，偶爾傳來翻頁的聲音。你仔細地查看了各個書架，但沒有發現任何異常。"
        case 1:
            return "一樓大廳寬敞明亮，櫃檯後方的館員正專注地整理著剛歸還的書籍。幾個電腦終端供查詢使用，牆上掛著臺大歷史的老照片。你向館員詢問了一些問題，但她只是禮貌地建議你自行探索圖書館。"
        case 4:
            return "地下室燈火通明，意外地熱鬧。一群學生圍坐在桌前，專心致志地閱讀和討論，看來是在準備考試。偶爾傳來輕聲的討論和筆記本翻頁的聲音。空氣中有一絲涼意，但學習的熱情似乎驅散了這份寒冷。"
        default:
            return ""
        }
    }
}

struct LibraryFloorDetailView: View {
    let floor: Int
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(floor == 4 ? "地下室" : "\(floor)樓探索")
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}
