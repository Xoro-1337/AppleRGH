import SwiftUI
import Watch360Core

public struct RemoteMemoryView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    @State private var hexAddress: String = "82000000"
    @State private var hexValue: String = "60000000"
    @State private var peekResult: String = ""
    @State private var isPeeking = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Remote D-Pad & Guide Controls
                VStack(spacing: 6) {
                    Text("SHORTCUTS & REMOTE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Guide Button
                    Button {
                        // Guide button simulation via XBDM/JRPC
                        manager.sendXNotify(message: "Xbox Guide Opened", logo: .xboxLogo)
                    } label: {
                        HStack {
                            Image(systemName: "xbox.logo")
                                .font(.system(size: 12))
                            Text("Xbox Guide")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.06, green: 0.49, blue: 0.06))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    
                    // Simple Virtual D-Pad
                    VStack(spacing: 4) {
                        Button {
                            // D-pad Up
                            manager.playHaptic(.click)
                        } label: {
                            Image(systemName: "chevron.up")
                                .frame(width: 32, height: 24)
                                .background(Color(white: 0.18))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        
                        HStack(spacing: 12) {
                            Button {
                                // D-pad Left
                                manager.playHaptic(.click)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .frame(width: 32, height: 24)
                                    .background(Color(white: 0.18))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            
                            // Center A button
                            Button {
                                manager.playHaptic(.click)
                            } label: {
                                Text("A")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundColor(.green)
                                    .frame(width: 32, height: 24)
                                    .background(Color(white: 0.18))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                // D-pad Right
                                manager.playHaptic(.click)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .frame(width: 32, height: 24)
                                    .background(Color(white: 0.18))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button {
                            // D-pad Down
                            manager.playHaptic(.click)
                        } label: {
                            Image(systemName: "chevron.down")
                                .frame(width: 32, height: 24)
                                .background(Color(white: 0.18))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(6)
                    .background(Color(white: 0.12))
                    .cornerRadius(8)
                }
                
                // Memory Peek / Poke Section
                VStack(spacing: 6) {
                    Text("MEMORY PEEK / POKE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Address (Hex)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        TextField("82000000", text: $hexAddress)
                            .font(.system(size: 10, design: .monospaced))
                            .padding(4)
                            .background(Color(white: 0.15))
                            .cornerRadius(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Value (Hex)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        TextField("60000000", text: $hexValue)
                            .font(.system(size: 10, design: .monospaced))
                            .padding(4)
                            .background(Color(white: 0.15))
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 6) {
                        // Peek Button
                        Button {
                            guard let addr = UInt32(hexAddress.replacingOccurrences(of: "0x", with: ""), radix: 16) else { return }
                            isPeeking = true
                            Task {
                                let result = await manager.peekMemory(address: addr, length: 4)
                                self.peekResult = result
                                self.isPeeking = false
                            }
                        } label: {
                            Text(isPeeking ? "..." : "Peek")
                                .font(.system(size: 10, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color(white: 0.2))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                        
                        // Poke Button
                        Button {
                            guard let addr = UInt32(hexAddress.replacingOccurrences(of: "0x", with: ""), radix: 16) else { return }
                            manager.pokeMemory(address: addr, hexData: hexValue)
                        } label: {
                            Text("Poke")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.06, green: 0.49, blue: 0.06))
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(!manager.isConnected)
                    }
                    
                    if !peekResult.isEmpty {
                        Text("Result: \(peekResult)")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.green)
                            .padding(.top, 2)
                    }
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Remote")
    }
}
