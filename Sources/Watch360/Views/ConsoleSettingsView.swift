import SwiftUI
#if canImport(Watch360Core)
import Watch360Core
#endif

public struct ConsoleSettingsView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    @State private var consoleName: String = ""
    @State private var consoleIp: String = ""
    @State private var consolePort: String = "730"
    @State private var showingEditProfile = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Active Profile Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("ACTIVE CONSOLE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(manager.activeProfile.name)
                                .font(.system(size: 12, weight: .bold))
                            Text("\(manager.activeProfile.ipAddress):\(manager.activeProfile.port)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Button {
                            consoleName = manager.activeProfile.name
                            consoleIp = manager.activeProfile.ipAddress
                            consolePort = "\(manager.activeProfile.port)"
                            showingEditProfile = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
                
                // Preferences Section
                VStack(spacing: 6) {
                    Text("PREFERENCES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Temp Unit Toggle
                    HStack {
                        Text("Temperature Unit")
                            .font(.system(size: 11))
                        Spacer()
                        Button {
                            manager.toggleTemperatureUnit()
                        } label: {
                            Text(manager.isFahrenheit ? "°F" : "°C")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(white: 0.2))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(white: 0.12))
                    .cornerRadius(8)
                    
                    // Demo / Mock Mode Toggle
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Demo / Mock Mode")
                                .font(.system(size: 11, weight: .medium))
                            Text("Simulate live RGH telemetry")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { manager.isMockMode },
                            set: { _ in manager.toggleMockMode() }
                        ))
                        .labelsHidden()
                    }
                    .padding(8)
                    .background(Color(white: 0.12))
                    .cornerRadius(8)
                }
                
                // About / Help
                VStack(alignment: .leading, spacing: 3) {
                    Text("ABOUT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text("Watch360 RGH/JTAG Toolbox")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Requires xbdm.xex and jrpc2.xex loaded on Xbox 360 via DashLaunch.")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingEditProfile) {
            ScrollView {
                VStack(spacing: 8) {
                    Text("Edit Xbox Console")
                        .font(.system(size: 12, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Name").font(.system(size: 9)).foregroundColor(.secondary)
                        TextField("Living Room RGH", text: $consoleName)
                            .font(.system(size: 11))
                            .padding(4)
                            .background(Color(white: 0.2))
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("IP Address").font(.system(size: 9)).foregroundColor(.secondary)
                        TextField("192.168.1.100", text: $consoleIp)
                            .font(.system(size: 11, design: .monospaced))
                            .padding(4)
                            .background(Color(white: 0.2))
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Port").font(.system(size: 9)).foregroundColor(.secondary)
                        TextField("730", text: $consolePort)
                            .font(.system(size: 11, design: .monospaced))
                            .padding(4)
                            .background(Color(white: 0.2))
                            .cornerRadius(4)
                    }
                    
                    Button {
                        let portNum = Int(consolePort) ?? 730
                        var updated = manager.activeProfile
                        updated.name = consoleName.isEmpty ? "My Xbox 360" : consoleName
                        updated.ipAddress = consoleIp.isEmpty ? "192.168.1.100" : consoleIp
                        updated.port = portNum
                        manager.saveProfile(updated)
                        showingEditProfile = false
                    } label: {
                        Text("Save")
                            .font(.system(size: 11, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding()
            }
        }
    }
}
