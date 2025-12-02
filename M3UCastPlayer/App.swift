import SwiftUI
import AVKit

@main
struct M3UCastPlayerApp: App {
    @StateObject private var playerViewModel = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerViewModel)
        }
    }
}
