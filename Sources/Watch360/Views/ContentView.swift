import SwiftUI
import Watch360Core

public struct ContentView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Top Hero Status Card
                    heroStatusCard
                    
                    // Quick Navigation Menu Cards
                    VStack(spacing: 6) {
                        NavigationLink(destination: DashboardPowerView()) {
                            menuRow(
                                title: "Power Controls",
                                subtitle: "Reboot, Off, Freeze, Tray",
                                icon: "power.circle.fill",
                                color: .orange
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: TelemetryView()) {
                            menuRow(
                                title: "Hardware Sensors",
                                subtitle: "CPU, GPU, Fan, Temps",
                                icon: "gauge.with.needle.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: XNotifyView()) {
                            menuRow(
                                title: "XNotify Toast",
                                subtitle: "Send messages to TV HUD",
                                icon: "bell.badge.fill",
                                color: .cyan
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: TitleLauncherView()) {
                            menuRow(
                                title: "Title Launcher",
                                subtitle: "Aurora, FSD, Custom XEX",
                                icon: "play.circle.fill",
                                color: .yellow
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: RingOfLightView()) {
                            menuRow(
                                title: "Ring of Light",
                                subtitle: "Quadrant LED Controller",
                                icon: "circle.grid.2x2.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: RemoteMemoryView()) {
                            menuRow(
                                title: "Remote & Memory",
                                subtitle: "Guide, D-Pad, Peek/Poke",
                                icon: "memorychip.fill",
                                color: .purple
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: ConsoleSettingsView()) {
                            menuRow(
                                title: "Settings",
                                subtitle: "IP, Profiles, Demo Mode",
                                icon: "gearshape.fill",
                                color: .gray
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Watch360")
        }
    }
    
    // MARK: - Hero Status Card
    
    private var heroStatusCard: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                // Connection Pulse Dot
                Circle()
                    .fill(manager.isConnected ? Color.green : (manager.isConnecting ? Color.yellow : Color.red))
                    .frame(width: 10, height: 10)
                    .shadow(color: manager.isConnected ? Color.green.opacity(0.8) : Color.clear, radius: 4)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(manager.activeProfile.name)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text(manager.lastStatusMessage)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                
                // One-tap Connect Button
                Button {
                    manager.toggleConnection()
                } label: {
                    Text(manager.isConnecting ? "..." : (manager.isConnected ? "Disconnect" : "Connect"))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(manager.isConnected ? Color.red.opacity(0.8) : Color(red: 0.06, green: 0.49, blue: 0.06))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
            
            // Glanceable Telemetry Pill (when connected)
            if manager.isConnected {
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Text("CPU")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(manager.telemetry.formattedTemp(celsius: manager.telemetry.cpuTempC, isFahrenheit: manager.isFahrenheit))
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.green)
                    }
                    
                    Text("•").foregroundColor(.secondary).font(.system(size: 8))
                    
                    HStack(spacing: 3) {
                        Text("GPU")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(manager.telemetry.formattedTemp(celsius: manager.telemetry.gpuTempC, isFahrenheit: manager.isFahrenheit))
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    Text(manager.telemetry.titleName)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.orange)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
        }
        .padding(8)
        .background(Color(white: 0.12))
        .cornerRadius(10)
    }
    
    // MARK: - Menu Row Helper
    
    private func menuRow(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(white: 0.35))
        }
        .padding(8)
        .background(Color(white: 0.12))
        .cornerRadius(8)
    }
}
