import SwiftUI
#if canImport(Watch360Core)
import Watch360Core
#endif

public struct XNotifyView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    @State private var customMessage: String = ""
    @State private var selectedLogo: XNotifyLogo = .flashingXboxLogo
    @State private var showingLogoPicker = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Custom Message Section
                VStack(spacing: 8) {
                    Text("CUSTOM TOAST")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter message...", text: $customMessage)
                        .font(.system(size: 12))
                        .padding(6)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                    
                    // Logo Selector Button
                    Button {
                        showingLogoPicker.toggle()
                    } label: {
                        HStack {
                            Image(systemName: selectedLogo.systemImage)
                                .foregroundColor(.green)
                            Text(selectedLogo.displayName)
                                .font(.system(size: 11, weight: .medium))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    // Send Button
                    Button {
                        guard !customMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        manager.sendXNotify(message: customMessage, logo: selectedLogo)
                        customMessage = ""
                    } label: {
                        HStack {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 12))
                            Text("Send to TV")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(customMessage.isEmpty ? Color.gray.opacity(0.4) : Color(red: 0.06, green: 0.49, blue: 0.06))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(customMessage.trimmingCharacters(in: .whitespaces).isEmpty || !manager.isConnected)
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(10)
                
                // Quick Presets Section
                VStack(spacing: 6) {
                    Text("QUICK PRESETS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(XNotifyPreset.defaults) { preset in
                        Button {
                            manager.sendXNotify(message: preset.message, logo: preset.logo)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: preset.logo.systemImage)
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                    .frame(width: 16)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(preset.title)
                                        .font(.system(size: 11, weight: .semibold))
                                    Text(preset.message)
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(8)
                            .background(Color(white: 0.15))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("XNotify")
        .sheet(isPresented: $showingLogoPicker) {
            ScrollView {
                VStack(spacing: 4) {
                    Text("Select Icon")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.bottom, 4)
                    
                    ForEach(XNotifyLogo.allCases) { logo in
                        Button {
                            selectedLogo = logo
                            showingLogoPicker = false
                        } label: {
                            HStack {
                                Image(systemName: logo.systemImage)
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                Text(logo.displayName)
                                    .font(.system(size: 11))
                                Spacer()
                                if selectedLogo == logo {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(6)
                            .background(Color(white: 0.15))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
