import SwiftUI
import Watch360Core

@main
struct Watch360iOSApp: App {
    @StateObject private var manager = XboxToolboxManager()
    
    var body: some Scene {
        WindowGroup {
            iOSContentView()
                .environmentObject(manager)
                .preferredColorScheme(.dark)
        }
    }
}
