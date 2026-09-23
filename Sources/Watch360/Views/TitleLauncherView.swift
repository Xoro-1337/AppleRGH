import SwiftUI
import Watch360Core

public struct TitleLauncherView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    @State private var customPath: String = ""
    @State private var showingLaunchConfirmation = false
    @State private var selectedPathToLaunch = ""
    @State private var selectedNameToLaunch = ""
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Active Title Header
                VStack(alignment: .leading, spacing: 3) {
                    Text("ACTIVE TITLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(manager.telemetry.titleName)
                                .font(.system(size: 12, weight: .bold))
                                .lineLimit(1)
                            Text("ID: \(manager.telemetry.titleId)")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
                
                // Dashboards & Launchers
                VStack(spacing: 6) {
                    Text("QUICK LAUNCH")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(QuickLaunchTitle.defaults) { item in
                        Button {
                            selectedPathToLaunch = item.xexPath
                            selectedNameToLaunch = item.name
                            showingLaunchConfirmation = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                    .frame(width: 16)
                                
                                Text(item.name)
                                    .font(.system(size: 11, weight: .semibold))
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color(white: 0.15))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                    }
                }
                
                // Custom XEX Launcher
                VStack(spacing: 6) {
                    Text("CUSTOM XEX PATH")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("e.g. Hdd:\\default.xex", text: $customPath)
                        .font(.system(size: 10, design: .monospaced))
                        .padding(6)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                    
                    Button {
                        guard !customPath.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        selectedPathToLaunch = customPath
                        selectedNameToLaunch = "Custom Title"
                        showingLaunchConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.forward.app.fill")
                                .font(.system(size: 11))
                            Text("Launch XEX")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(customPath.isEmpty ? Color.gray.opacity(0.4) : Color(red: 0.06, green: 0.49, blue: 0.06))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .disabled(customPath.trimmingCharacters(in: .whitespaces).isEmpty || !manager.isConnected)
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Launcher")
        .confirmationDialog(
            "Launch \(selectedNameToLaunch)?",
            isPresented: $showingLaunchConfirmation,
            titleVisibility: .visible
        ) {
            Button("Launch") {
                manager.launchTitle(path: selectedPathToLaunch)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
