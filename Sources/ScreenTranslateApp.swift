import SwiftUI

@main
struct ScreenTranslateApp: App {
    @StateObject private var pending = PendingScreenshot.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pending)
        }
    }
}
