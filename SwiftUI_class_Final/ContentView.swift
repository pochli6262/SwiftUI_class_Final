import SwiftUI
import MapKit

// MARK: - 道具／信物

enum Item: String, CaseIterable, Identifiable, Hashable {
    // 行進順序：圖書館→德田館→新體→活大→天文數學館→傅鐘
    case libraryNote       // 從總圖三樓取得的紙條
    case squashRacket      // 德田館取得
    case mcdCoupon         // 新體骰子勝利取得
    case decryptionKey     // 活大幫老人後取得
    case fuBellClue        // 天文數學館輸入 FUBELL 後取得（提示）
    case fuBellToken       // 傅鐘答題正確後取得（最後信物）

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .libraryNote:   return "紙條線索"
        case .squashRacket:  return "壁球拍"
        case .mcdCoupon:     return "麥當勞優惠券"
        case .decryptionKey: return "密鑰 d=3"
        case .fuBellClue:    return "FUBELL 提示"
        case .fuBellToken:   return "傅鐘咒物"
        }
    }
}

// MARK: - 校園座標 / 地點

struct NTULocation: Identifiable {
    enum Kind: String, CaseIterable, Identifiable, Hashable {
        case library, powerPlant, sportsCenter, activityCenter, astronomyMath, fuBell, lakePavilion, freshmanCenter
        var id: Self { self }
    }

    var id: Kind
    var name: String
    var coordinate: CLLocationCoordinate2D
}

// `CLLocationCoordinate2D` 並未遵循 `Hashable`，因此自訂 `Equatable` / `Hashable` 只比對 id
extension NTULocation: Equatable {
    static func == (lhs: NTULocation, rhs: NTULocation) -> Bool { lhs.id == rhs.id }
}
extension NTULocation: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - 遊戲狀態

class GameState: ObservableObject {
    @Published var inventory: Set<Item> = []            // 已取得道具
    @Published var summonCompleted = false              // 是否已在湖心亭完成召喚

    private let tokensForSummon: [Item] = [.libraryNote, .squashRacket, .mcdCoupon, .decryptionKey, .fuBellToken]

    func hasAllTokens() -> Bool {
        tokensForSummon.allSatisfy(inventory.contains)
    }
}

// MARK: - App 入口

struct ContentView: View {
    @StateObject private var game = GameState()
    @State private var showStory = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image("library")
                    .resizable()
                    .frame(width: 300, height: 300)
                Text("NTU Puzzle Adventure")
                    .font(.largeTitle.bold())
                Text("點擊開始，展開你的臺大解謎之旅")
                    .multilineTextAlignment(.center)
                Button("開始遊戲") { showStory = true }
                    .buttonStyle(.borderedProminent)
                Spacer()
            }
            .navigationDestination(isPresented: $showStory) {
                StoryIntroView().environmentObject(game)
            }
        }
    }
}

struct StoryIntroView: View {
    @EnvironmentObject var game: GameState
    @State private var goMap = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
//            ScrollView {
//                Text("""
//你是一位即將成為臺大人的新生，但你尚未取得入學證明。如果在開學前拿不到入學證明，你將失去入學資格！
//
//神秘之音：「去找吧！我把所有入學證明都藏那裡！」
//
//你茫然地站在校門口，只能先去總圖看看......
//""")
//            }
            Image("introduction")
                .resizable()
                .frame(width: 400, height: 400)
            Button("前往總圖") { goMap = true }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationDestination(isPresented: $goMap) {
            MapView().environmentObject(game)
        }
    }
}


// MARK: - 地圖
fileprivate var starOverlay: MKPolyline {
    let coords = [
        CLLocationCoordinate2D(latitude: 25.019413171057344, longitude: 121.54146077741073), // 德田館
        CLLocationCoordinate2D(latitude: 25.017747006918007, longitude: 121.54009100247073), // 活大
        CLLocationCoordinate2D(latitude: 25.017148824993487, longitude: 121.53675931382348), // 傅鐘
        CLLocationCoordinate2D(latitude: 25.02145867241166,  longitude: 121.5352765185534),  // 新體
        CLLocationCoordinate2D(latitude: 25.021165836401224, longitude: 121.5380799500072),  // 天文數學館
        CLLocationCoordinate2D(latitude: 25.019413171057344, longitude: 121.54146077741073)  // 回德田館
    ]
    return MKPolyline(coordinates: coords, count: coords.count)
}


//struct MapView: View {
//    @EnvironmentObject var game: GameState
//
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 25.0182, longitude: 121.5395),
//        span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
//    )
//    @State private var selected: NTULocation?
//
//    private let locations: [NTULocation] = [
//        NTULocation(id: .library,          name: "臺大圖書館",     coordinate: .init(latitude: 25.01738368914369, longitude: 121.54050473271329)),
//        NTULocation(id: .powerPlant,       name: "德田館",         coordinate: .init(latitude: 25.019413171057344, longitude: 121.54146077741073)),
//        NTULocation(id: .sportsCenter,     name: "新體",           coordinate: .init(latitude: 25.02145867241166, longitude: 121.5352765185534)),
//        NTULocation(id: .activityCenter,   name: "活大",           coordinate: .init(latitude: 25.017747006918007, longitude: 121.54009100247073)),
//        NTULocation(id: .astronomyMath,    name: "天文數學館",     coordinate: .init(latitude: 25.021165836401224, longitude:  121.5380799500072)),
//        NTULocation(id: .fuBell,           name: "傅鐘",           coordinate: .init(latitude: 25.017148824993487, longitude: 121.53675931382348)),
//        NTULocation(id: .lakePavilion,     name: "醉月湖心亭",     coordinate: .init(latitude: 25.020413267215982, longitude: 121.53762270312905)),
//        NTULocation(id: .freshmanCenter,   name: "新生教學館",     coordinate: .init(latitude: 25.019715897298074, longitude:  121.53844525959417))
//    ]
//
//    var body: some View {
//        ZStack {
//            Map(coordinateRegion: $region, annotationItems: locations) { loc in
//                // iOS17 建議使用 `Annotation`; 這裡為了簡潔仍用 MapAnnotation，僅出現警告
//                MapAnnotation(coordinate: loc.coordinate) {
//                    Button { selected = loc } label: {
//                        Image(systemName: "mappin.circle.fill")
//                            .font(.title)
//                            .foregroundColor(loc.id == .freshmanCenter && game.summonCompleted ? .yellow : .red)
//                    }
//                }
//            }
//
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    InventoryView().environmentObject(game).padding()
//                }
//            }
//        }
//        .sheet(item: $selected) { LocationRouterView(location: $0).environmentObject(game) }
//        .onChange(of: game.summonCompleted) { done in
//            guard done, let freshman = locations.first(where: { $0.id == .freshmanCenter }) else { return }
//            region.center = freshman.coordinate
//        }
//        .navigationTitle("臺大地圖探索")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

struct InventoryView: View {
    @EnvironmentObject var game: GameState
    var body: some View {
        VStack(alignment: .leading) {
            Text("背包").bold()
            ForEach(Array(game.inventory)) { item in
                Text(item.displayName).font(.caption)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Location Router

struct LocationRouterView: View {
    let location: NTULocation
    @EnvironmentObject var game: GameState

    var body: some View {
        switch location.id {
        case .library:         LibraryView()
        case .powerPlant:      PowerPlantView()
        case .sportsCenter:    SportsCenterView()
        case .activityCenter:  ActivityCenterView()
        case .astronomyMath:   AstronomyMathView()
        case .fuBell:          FuBellView()
        case .lakePavilion:    LakePavilionView()
        case .freshmanCenter:  FreshmanCenterView()
        }
    }
}


struct MapView: View {
    @EnvironmentObject var game: GameState
    @State private var selected: NTULocation?

    private let locations: [NTULocation] = [
        NTULocation(id: .library,        name: "臺大圖書館",   coordinate: .init(latitude: 25.01738368914369, longitude: 121.54050473271329)),
        NTULocation(id: .powerPlant,     name: "德田館",       coordinate: .init(latitude: 25.019413171057344, longitude: 121.54146077741073)),
        NTULocation(id: .sportsCenter,   name: "新體",         coordinate: .init(latitude: 25.02145867241166, longitude: 121.5352765185534)),
        NTULocation(id: .activityCenter, name: "活大",         coordinate: .init(latitude: 25.017747006918007, longitude: 121.54009100247073)),
        NTULocation(id: .astronomyMath,  name: "天文數學館",   coordinate: .init(latitude: 25.021165836401224, longitude:  121.5380799500072)),
        NTULocation(id: .fuBell,         name: "傅鐘",         coordinate: .init(latitude: 25.017148824993487, longitude: 121.53675931382348)),
        NTULocation(id: .lakePavilion,   name: "醉月湖心亭",   coordinate: .init(latitude: 25.020413267215982, longitude: 121.53762270312905)),
        NTULocation(id: .freshmanCenter, name: "新生教學館",   coordinate: .init(latitude: 25.019715897298074, longitude:  121.53844525959417))
    ]

    var body: some View {
        ZStack {
            UIKitMapView(game: game, locations: locations, selected: $selected)
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    InventoryView().environmentObject(game).padding()
                }
            }
        }
        .sheet(item: $selected) {
            LocationRouterView(location: $0).environmentObject(game)
        }
        .navigationTitle("臺大地圖探索")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UIKitMapView: UIViewRepresentable {
    let game: GameState
    let locations: [NTULocation]
    @Binding var selected: NTULocation?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.0182, longitude: 121.5395),
            span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        )
        map.setRegion(region, animated: false)

        for loc in locations {
            let annotation = MKPointAnnotation()
            annotation.title = loc.id.rawValue
            annotation.coordinate = loc.coordinate
            map.addAnnotation(annotation)
        }

        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)

        if game.summonCompleted {
            let coords: [CLLocationCoordinate2D] = [
                CLLocationCoordinate2D(latitude: 25.019413171057344, longitude: 121.54146077741073),
                CLLocationCoordinate2D(latitude: 25.02145867241166,  longitude: 121.5352765185534),
                CLLocationCoordinate2D(latitude: 25.017747006918007, longitude: 121.54009100247073),
                CLLocationCoordinate2D(latitude: 25.021165836401224, longitude: 121.5380799500072),
                CLLocationCoordinate2D(latitude: 25.017148824993487, longitude: 121.53675931382348),
                CLLocationCoordinate2D(latitude: 25.019413171057344, longitude: 121.54146077741073)
            ]
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            mapView.addOverlay(polyline)
        }

        // ✅ 強制刷新圖標顏色
        mapView.annotations.forEach { annotation in
            if let view = mapView.view(for: annotation) {
                let isFreshman = annotation.title == NTULocation.Kind.freshmanCenter.rawValue
                view.image = coloredPinImage(color: isFreshman && game.summonCompleted ? UIColor.systemYellow : UIColor.systemRed)
            }
        }
    }



    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: UIKitMapView

        init(_ parent: UIKitMapView) {
            self.parent = parent
        }

        func coloredPinImage(color: UIColor) -> UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            guard let base = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)?
                    .withRenderingMode(.alwaysTemplate) else {
                return UIImage()
            }

            let size = CGSize(width: 40, height: 40)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                color.set()
                base.draw(in: CGRect(origin: .zero, size: size))
            }
        }


        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let idRaw = annotation.title ?? nil,
                  let loc = parent.locations.first(where: { $0.id.rawValue == idRaw }) else { return nil }

            let identifier = "pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if view == nil {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false
                view?.frame.size = CGSize(width: 32, height: 32)
            } else {
                view?.annotation = annotation
            }

            let color: UIColor = (loc.id == .freshmanCenter && parent.game.summonCompleted) ? .systemYellow : .systemRed
            view?.image = coloredPinImage(color: color)
            view?.tintColor = .clear

            return view
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemPink
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let idRaw = view.annotation?.title ?? nil,
                  let loc = parent.locations.first(where: { $0.id.rawValue == idRaw }) else { return }
            parent.selected = loc
        }
    }
}

func coloredPinImage(color: UIColor) -> UIImage {
    let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
    guard let base = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)?
        .withRenderingMode(.alwaysTemplate) else {
        return UIImage()
    }

    let size = CGSize(width: 40, height: 40)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        color.set()
        base.draw(in: CGRect(origin: .zero, size: size))
    }
}



// MARK: -  Preview

#Preview {
    ContentView()
}
