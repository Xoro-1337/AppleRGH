import SwiftUI
#if canImport(Watch360Core)
import Watch360Core
#endif

struct iOSContentView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Circle()
                                .fill(manager.isConnected ? Color.green : Color.red)
                                .frame(width: 12, height: 12)
                            Text(manager.activeProfile.name)
                                .font(.title2.bold())
                            Spacer()
                            Text(manager.isConnected ? "Online" : "Offline")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(manager.lastStatusMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            manager.toggleConnection()
                        } label: {
                            HStack {
                                Image(systemName: manager.isConnected ? "link.badge.plus" : "link")
                                Text(manager.isConnecting ? "Connecting..." : (manager.isConnected ? "Disconnect" : "Connect to Console"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(manager.isConnected ? Color.red : Color(red: 0.06, green: 0.49, blue: 0.06))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(16)
                    
                    // AltStore / Apple Watch Info Banner
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "applewatch")
                                .font(.title)
                                .foregroundColor(.green)
                            Text("Apple Watch App Installed")
                                .font(.headline)
                        }
                        Text("Watch360 is synced with your paired Apple Watch. Open the Watch app on your wrist or use this phone companion to manage your console!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(16)
                    
                    // Quick Power Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("POWER CONTROLS")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            actionButton(title: "Warm Reboot", icon: "arrow.clockwise.circle.fill", color: .orange) {
                                manager.reboot(cold: false)
                            }
                            actionButton(title: "Cold Reboot", icon: "bolt.circle.fill", color: .yellow) {
                                manager.reboot(cold: true)
                            }
                            actionButton(title: "Shutdown", icon: "power.circle.fill", color: .red) {
                                manager.shutdown()
                            }
                        }
                    }
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Watch360 Companion")
        }
    }
    
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(white: 0.18))
            .cornerRadius(10)
        }
        .disabled(!manager.isConnected)
    }
}
