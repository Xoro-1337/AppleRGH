import SwiftUI
import Watch360Core

@main
public struct Watch360App: App {
    @StateObject private var manager = XboxToolboxManager()
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
                .preferredColorScheme(.dark)
                .tint(Color(red: 0.06, green: 0.49, blue: 0.06)) // Xbox Green
        }
    }
}
