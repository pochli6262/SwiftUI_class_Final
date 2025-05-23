import SwiftUI
import MapKit

struct GameLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let description: String
    let key: String // 對應解鎖條件，例如 "library", "tian" 等
}

enum CurrentScene {
    case login, storyIntro, map, libraryExplore, tianHallPuzzle
}

enum LibraryStage: String, CaseIterable {
    case basement, firstFloor, secondFloor, thirdFloor, hintFound
}

class GameState: ObservableObject {
    @Published var username: String = ""
    @Published var currentScene: CurrentScene = .login
    @Published var unlocked: Set<String> = ["library"]
    @Published var inventory: [String] = []
    @Published var libraryStage: LibraryStage = .basement
    @Published var libraryExplored: Set<LibraryStage> = []
    @Published var tianPuzzleAnswered: Bool = false
    @Published var playerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 25.01738, longitude: 121.5405)


    func isUnlocked(_ key: String) -> Bool {
        unlocked.contains(key)
    }
    func unlock(_ key: String) {
        unlocked.insert(key)
    }
    func hasItem(_ item: String) -> Bool {
        inventory.contains(item)
    }
}

struct ContentView: View {
    @StateObject var gameState = GameState()

    var body: some View {
        switch gameState.currentScene {
        case .login:
            LoginView().environmentObject(gameState)
        case .storyIntro:
            StoryIntroView().environmentObject(gameState)
        case .map:
            MapSceneView().environmentObject(gameState)
        case .libraryExplore:
            LibraryExploreView().environmentObject(gameState)
        case .tianHallPuzzle:
            TianHallPuzzleView().environmentObject(gameState)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack(spacing: 20) {
            Text("🎓 台大新生實境解謎")
                .font(.largeTitle)
            TextField("請輸入暱稱", text: $gameState.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("開始遊戲") {
                gameState.currentScene = .storyIntro
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct StoryIntroView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack(spacing: 20) {
            Text("\(gameState.username) 同學，歡迎來到台大！")
                .font(.title2)
            Text("你是一名新生，想獲得真正的入場券，請從總圖開始探索。")
                .padding()
            Button("前往地圖") {
                gameState.currentScene = .map
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct MapSceneView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedLocation: GameLocation? = nil
    @State private var isMoving = false

    let locations: [GameLocation] = [
        GameLocation(name: "總圖書館", coordinate: CLLocationCoordinate2D(latitude: 25.01738, longitude: 121.5405), description: "探索書海的起點。", key: "library"),
        GameLocation(name: "德田館", coordinate: CLLocationCoordinate2D(latitude: 25.01941, longitude: 121.54146), description: "電神聚集之地。", key: "tian")
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapReader(
                locations: locations,
                selectedLocation: $selectedLocation,
                characterPosition: $gameState.playerPosition, // ✅ 從 gameState 傳入 Binding
                isMoving: $isMoving
            )
            if let location = selectedLocation {
                LocationDialog(location: location, show: $selectedLocation)
            }

            if !gameState.inventory.isEmpty {
                VStack(alignment: .trailing) {
                    Text("🎒 背包：")
                        .font(.caption)
                        .bold()
                    ForEach(gameState.inventory, id: \.self) { item in
                        Text("• \(item)")
                            .font(.caption2)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding()
            }
        }
    }
}



// MapReader 加上角色圖示與動畫控制
struct MapReader: View {
    let locations: [GameLocation]
    @EnvironmentObject var gameState: GameState
    @Binding var selectedLocation: GameLocation?
    @Binding var characterPosition: CLLocationCoordinate2D
    @Binding var isMoving: Bool

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.0173, longitude: 121.5395),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
    )

    var body: some View {
        Map(position: $position) {
            // 地點標記
            ForEach(locations) { location in
                Annotation(location.name, coordinate: location.coordinate) {
                    Button {
                        if gameState.isUnlocked(location.key) {
                            isMoving = true
                            withAnimation(.easeInOut(duration: 1.2)) {
                                characterPosition = location.coordinate
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                selectedLocation = location
                                isMoving = false
                            }
                        }
                    } label: {
                        Image(systemName: gameState.isUnlocked(location.key) ? "mappin.circle.fill" : "lock.circle")
                            .font(.title)
                            .foregroundColor(gameState.isUnlocked(location.key) ? .blue : .gray)
                    }
                }
            }

            // 角色圖示
            Annotation("Player", coordinate: characterPosition) {
                Image(systemName: "figure.walk.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.red)
                    .scaleEffect(isMoving ? 1.2 : 1.0)
                    .shadow(radius: 3)
                    .animation(.easeInOut(duration: 0.5), value: isMoving)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



struct LocationDialog: View {
    let location: GameLocation
    @EnvironmentObject var gameState: GameState
    @Binding var show: GameLocation?

    var body: some View {
        VStack(spacing: 12) {
            Text(location.name)
                .font(.headline)
            Text(location.description)
            if gameState.isUnlocked(location.key) {
                Button("進入") {
                    show = nil
                    if location.key == "library" {
                        gameState.libraryStage = .basement
                        gameState.libraryExplored = []
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            gameState.currentScene = .libraryExplore
                        }
                    } else if location.key == "tian" {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            gameState.currentScene = .tianHallPuzzle
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("目前尚未解鎖")
                    .foregroundColor(.gray)
            }
            Button("關閉") {
                show = nil
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

struct LibraryExploreView: View {
    @EnvironmentObject var gameState: GameState

    func explore(_ stage: LibraryStage) {
        gameState.libraryStage = stage
        gameState.libraryExplored.insert(stage)
        if stage == .thirdFloor {
            gameState.libraryStage = .hintFound
            gameState.unlock("tian")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("📚 總圖探索 - 選擇樓層")
                .font(.headline)
            ForEach(LibraryStage.allCases.filter { $0 != .hintFound }, id: \ .self) { stage in
                Button("探索 \(floorName(for: stage))") {
                    explore(stage)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }

            Divider()
            if let output = narrative(for: gameState.libraryStage) {
                Text(output)
                    .padding()
            }

            if gameState.libraryStage == .hintFound {
                Button("回到地圖") {
                    gameState.currentScene = .map
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }

    func floorName(for stage: LibraryStage) -> String {
        switch stage {
        case .basement: return "地下室"
        case .firstFloor: return "一樓"
        case .secondFloor: return "二樓"
        case .thirdFloor: return "三樓"
        case .hintFound: return "完成探索"
        }
    }

    func narrative(for stage: LibraryStage) -> String? {
        switch stage {
        case .basement: return "你走進地下室，燈火通明但空無一人。"
        case .firstFloor: return "一樓擺滿書桌，但似乎沒有任何線索。"
        case .secondFloor: return "書堆凌亂，但一無所獲。"
        case .thirdFloor: return "你在書架後方發現一張泛黃紙條，上面寫著：電神之地，藏著前進的鑰匙。"
        case .hintFound: return "你已發現前往德田館的線索！"
        }
    }
}

struct TianHallPuzzleView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedAnswer: String? = nil
    @State private var showResult = false

    let question = "以下何者為『非監督式學習』？"
    let options = ["k-means", "decision tree", "xgboost", "logistic regression"]
    let correct = "k-means"

    var body: some View {
        VStack(spacing: 20) {
            Text("⚡ 德田館 - 電神之地")
                .font(.headline)
            Text("你來到103教室的講桌前，發現一張卡片：")
            Text(question)
                .bold()
            ForEach(options, id: \ .self) { opt in
                Button(opt) {
                    selectedAnswer = opt
                    showResult = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(opt == selectedAnswer ? Color.blue.opacity(0.6) : Color.gray.opacity(0.2))
                .cornerRadius(10)
            }

            if showResult {
                if selectedAnswer == correct {
                    Text("✅ 答對了！你發現藏在抽屜的訊息：紅黑樹研究異常，請前往專研樹之地。")
                        .padding()
                    Button("回到地圖") {
                        gameState.tianPuzzleAnswered = true
                        gameState.currentScene = .map
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Text("❌ 錯誤答案，再思考看看！")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}


#Preview{
    ContentView()
}
