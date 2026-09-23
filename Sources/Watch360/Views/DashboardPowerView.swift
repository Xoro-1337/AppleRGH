import SwiftUI
#if canImport(Watch360Core)
import Watch360Core
#endif

public struct DashboardPowerView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    @State private var showingRebootConfirmation = false
    @State private var showingShutdownConfirmation = false
    @State private var isColdReboot = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header Status Card
                HStack(spacing: 8) {
                    Circle()
                        .fill(manager.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(manager.activeProfile.name)
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                        Text(manager.lastStatusMessage)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color(white: 0.12))
                .cornerRadius(10)
                
                // Primary Connection Button
                Button {
                    manager.toggleConnection()
                } label: {
                    HStack {
                        Image(systemName: manager.isConnected ? "link.badge.plus" : "link")
                            .font(.system(size: 14, weight: .bold))
                        Text(manager.isConnecting ? "Connecting..." : (manager.isConnected ? "Disconnect" : "Connect"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(manager.isConnected ? Color.red.opacity(0.8) : Color(red: 0.06, green: 0.49, blue: 0.06))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                // Quick Power Actions Grid
                VStack(spacing: 8) {
                    Text("CONSOLE POWER")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 6) {
                        // Warm Reboot
                        Button {
                            isColdReboot = false
                            showingRebootConfirmation = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                Text("Warm")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                        
                        // Cold Reboot
                        Button {
                            isColdReboot = true
                            showingRebootConfirmation = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.yellow)
                                Text("Cold")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                        
                        // Shutdown
                        Button {
                            showingShutdownConfirmation = true
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "power.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                Text("Off")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                    }
                }
                
                // Hardware & Execution Toggles
                VStack(spacing: 8) {
                    Text("SYSTEM CONTROLS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 6) {
                        // Freeze / Unfreeze
                        Button {
                            manager.toggleFreeze()
                        } label: {
                            HStack {
                                Image(systemName: manager.isFrozen ? "play.fill" : "pause.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(manager.isFrozen ? .green : .cyan)
                                Text(manager.isFrozen ? "Resume" : "Freeze")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                        
                        // Eject Tray
                        Button {
                            manager.toggleTray()
                        } label: {
                            HStack {
                                Image(systemName: "eject.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.purple)
                                Text(manager.isTrayOpen ? "Close Tray" : "Eject Tray")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Power")
        .confirmationDialog(
            isColdReboot ? "Cold Reboot Console?" : "Warm Reboot Console?",
            isPresented: $showingRebootConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reboot", role: .destructive) {
                manager.reboot(cold: isColdReboot)
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Shutdown Xbox 360?",
            isPresented: $showingShutdownConfirmation,
            titleVisibility: .visible
        ) {
            Button("Shutdown", role: .destructive) {
                manager.shutdown()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
