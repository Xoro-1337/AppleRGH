import SwiftUI
#if canImport(Watch360Core)
import Watch360Core
#endif

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
