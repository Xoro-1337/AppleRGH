import Foundation
import Combine
#if canImport(WatchKit)
import WatchKit
#endif

@MainActor
public class XboxToolboxManager: ObservableObject {
    // MARK: - Published State
    @Published public var isConnected: Bool = false
    @Published public var isConnecting: Bool = false
    @Published public var isFrozen: Bool = false
    @Published public var isTrayOpen: Bool = false
    @Published public var telemetry: ConsoleTelemetry = ConsoleTelemetry()
    @Published public var activeProfile: XboxConsoleProfile = .default
    @Published public var profiles: [XboxConsoleProfile] = [.default]
    @Published public var lastStatusMessage: String = "Ready"
    @Published public var isMockMode: Bool = false
    @Published public var isFahrenheit: Bool = false
    @Published public var ringOfLight: RingOfLightState = .standardPlayer1
    @Published public var isPollingTelemetry: Bool = false
    
    // MARK: - Dependencies
    private let xbdmClient: XBDMClient
    private let jrpcClient: JRPCClient
    private var telemetryPollingTask: Task<Void, Never>?
    
    // MARK: - User Defaults Keys
    private let profilesKey = "com.watch360.savedProfiles"
    private let activeProfileIdKey = "com.watch360.activeProfileId"
    private let isFahrenheitKey = "com.watch360.isFahrenheit"
    private let isMockModeKey = "com.watch360.isMockMode"
    
    public init(
        xbdmClient: XBDMClient = XBDMClient(),
        jrpcClient: JRPCClient = JRPCClient()
    ) {
        self.xbdmClient = xbdmClient
        self.jrpcClient = jrpcClient
        loadSettings()
    }
    
    deinit {
        telemetryPollingTask?.cancel()
    }
    
    // MARK: - Connection Management
    
    public func toggleConnection() {
        if isConnected {
            disconnect()
        } else {
            connect()
        }
    }
    
    public func connect() {
        guard !isConnecting else { return }
        
        if isMockMode {
            playHaptic(.start)
            isConnecting = true
            lastStatusMessage = "Connecting to Demo Console..."
            
            Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                self.isConnecting = false
                self.isConnected = true
                self.telemetry = .sample
                self.lastStatusMessage = "Connected to Demo RGH"
                self.playHaptic(.success)
                self.startTelemetryPolling()
            }
            return
        }
        
        isConnecting = true
        lastStatusMessage = "Connecting to \(activeProfile.ipAddress)..."
        
        Task {
            do {
                // Try XBDM handshake
                let response = try await xbdmClient.connect(host: activeProfile.ipAddress, port: activeProfile.port)
                
                if response.isConnectedGreeting || response.isSuccess {
                    self.isConnected = true
                    self.isConnecting = false
                    self.lastStatusMessage = "Connected (XBDM/JRPC)"
                    self.playHaptic(.success)
                    
                    // Fetch initial console info
                    await self.refreshConsoleInfo()
                    
                    // Start polling
                    self.startTelemetryPolling()
                } else {
                    throw TransportError.connectionFailed("Unexpected response: \(response.message)")
                }
            } catch {
                self.isConnected = false
                self.isConnecting = false
                self.lastStatusMessage = "Failed: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func disconnect() {
        stopTelemetryPolling()
        
        if isMockMode {
            isConnected = false
            lastStatusMessage = "Disconnected"
            playHaptic(.stop)
            return
        }
        
        Task {
            await xbdmClient.disconnect()
            await jrpcClient.disconnect()
            self.isConnected = false
            self.lastStatusMessage = "Disconnected"
            self.playHaptic(.stop)
        }
    }
    
    // MARK: - Actions
    
    public func sendXNotify(message: String, logo: XNotifyLogo = .xboxLogo) {
        lastStatusMessage = "Sending Toast: \"\(message)\"..."
        
        if isMockMode {
            playHaptic(.notification)
            lastStatusMessage = "XNotify Sent: \(message)"
            return
        }
        
        Task {
            do {
                _ = try await jrpcClient.sendXNotify(message: message, logo: logo)
                self.lastStatusMessage = "Notification Sent!"
                self.playHaptic(.notification)
            } catch {
                // Fallback to plain XBDM if JRPC plugin is not loaded
                self.lastStatusMessage = "Error: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func reboot(cold: Bool) {
        lastStatusMessage = cold ? "Cold Rebooting..." : "Rebooting..."
        playHaptic(.directionUp)
        
        if isMockMode {
            disconnect()
            lastStatusMessage = cold ? "Console Cold Rebooted" : "Console Rebooted"
            return
        }
        
        Task {
            do {
                _ = try await xbdmClient.reboot(cold: cold)
                self.disconnect()
            } catch {
                self.lastStatusMessage = "Reboot failed: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func shutdown() {
        lastStatusMessage = "Shutting Down..."
        playHaptic(.stop)
        
        if isMockMode {
            disconnect()
            lastStatusMessage = "Console Powered Off"
            return
        }
        
        Task {
            do {
                _ = try await xbdmClient.shutdown()
                self.disconnect()
            } catch {
                // Also attempt JRPC shutdown
                _ = try? await self.jrpcClient.powerAction(3)
                self.disconnect()
            }
        }
    }
    
    public func toggleFreeze() {
        let willFreeze = !isFrozen
        lastStatusMessage = willFreeze ? "Freezing execution..." : "Resuming execution..."
        
        if isMockMode {
            isFrozen = willFreeze
            playHaptic(.click)
            lastStatusMessage = willFreeze ? "Console Frozen" : "Console Running"
            return
        }
        
        Task {
            do {
                if willFreeze {
                    _ = try await xbdmClient.freeze()
                } else {
                    _ = try await xbdmClient.unfreeze()
                }
                self.isFrozen = willFreeze
                self.lastStatusMessage = willFreeze ? "Console Frozen" : "Console Resumed"
                self.playHaptic(.click)
            } catch {
                self.lastStatusMessage = "Freeze error: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func toggleTray() {
        let willOpen = !isTrayOpen
        lastStatusMessage = willOpen ? "Ejecting tray..." : "Closing tray..."
        
        if isMockMode {
            isTrayOpen = willOpen
            playHaptic(.click)
            lastStatusMessage = willOpen ? "Tray Ejected" : "Tray Closed"
            return
        }
        
        Task {
            do {
                _ = try await xbdmClient.ejectTray()
                self.isTrayOpen = willOpen
                self.lastStatusMessage = willOpen ? "Tray Ejected" : "Tray Closed"
                self.playHaptic(.click)
            } catch {
                self.lastStatusMessage = "Tray error: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func launchTitle(path: String) {
        lastStatusMessage = "Launching: \(path)..."
        playHaptic(.directionUp)
        
        if isMockMode {
            telemetry.titleName = path.components(separatedBy: "\\").last ?? path
            lastStatusMessage = "Launched: \(telemetry.titleName)"
            return
        }
        
        Task {
            do {
                _ = try await xbdmClient.launchTitle(path: path)
                self.lastStatusMessage = "Launch command sent"
                self.playHaptic(.success)
            } catch {
                self.lastStatusMessage = "Launch error: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func updateRingOfLight(state: RingOfLightState) {
        self.ringOfLight = state
        playHaptic(.click)
        
        if isMockMode { return }
        
        Task {
            do {
                _ = try await jrpcClient.setRingOfLight(state: state)
            } catch {
                // Ignore LED error if JRPC is absent
            }
        }
    }
    
    public func pokeMemory(address: UInt32, hexData: String) {
        lastStatusMessage = String(format: "Poking 0x%08X...", address)
        
        if isMockMode {
            playHaptic(.success)
            lastStatusMessage = String(format: "Poked 0x%08X", address)
            return
        }
        
        Task {
            do {
                _ = try await xbdmClient.setMemory(address: address, hexData: hexData)
                self.lastStatusMessage = String(format: "Poked 0x%08X", address)
                self.playHaptic(.success)
            } catch {
                self.lastStatusMessage = "Poke error: \(error.localizedDescription)"
                self.playHaptic(.failure)
            }
        }
    }
    
    public func peekMemory(address: UInt32, length: Int = 4) async -> String {
        if isMockMode {
            return "DEADBEEF"
        }
        
        do {
            let data = try await xbdmClient.getMemory(address: address, length: length)
            return data
        } catch {
            return "ERR: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Telemetry & Polling
    
    private func refreshConsoleInfo() async {
        do {
            let kernel = (try? await jrpcClient.getKernelVersion()) ?? "2.0.17559.0"
            let consoleType = (try? await jrpcClient.getConsoleType()) ?? "Xbox 360 RGH"
            let titleInfo = (try? await xbdmClient.getTitleInfo()) ?? ("00000000", "Dashboard")
            
            self.telemetry.kernelVersion = kernel
            self.telemetry.consoleType = consoleType
            self.telemetry.titleId = titleInfo.titleId
            self.telemetry.titleName = titleInfo.name
        }
    }
    
    private func startTelemetryPolling() {
        stopTelemetryPolling()
        isPollingTelemetry = true
        
        telemetryPollingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                guard let self = self, self.isConnected else { break }
                
                await self.pollTelemetryOnce()
            }
        }
    }
    
    private func stopTelemetryPolling() {
        isPollingTelemetry = false
        telemetryPollingTask?.cancel()
        telemetryPollingTask = nil
    }
    
    private func pollTelemetryOnce() async {
        if isMockMode {
            // Realistic temperature fluctuations in demo mode
            let jitter = Double.random(in: -0.4...0.4)
            self.telemetry.cpuTempC = max(40.0, min(80.0, self.telemetry.cpuTempC + jitter))
            self.telemetry.gpuTempC = max(45.0, min(85.0, self.telemetry.gpuTempC + jitter * 0.8))
            self.telemetry.edramTempC = max(45.0, min(80.0, self.telemetry.edramTempC + jitter * 0.6))
            self.telemetry.motherboardTempC = max(30.0, min(55.0, self.telemetry.motherboardTempC + jitter * 0.2))
            self.telemetry.lastUpdated = Date()
            return
        }
        
        do {
            let temps = try await jrpcClient.getTemperatures()
            self.telemetry.cpuTempC = temps.cpu
            self.telemetry.gpuTempC = temps.gpu
            self.telemetry.edramTempC = temps.edram
            self.telemetry.motherboardTempC = temps.mb
            self.telemetry.lastUpdated = Date()
        } catch {
            // Skip failed poll
        }
    }
    
    // MARK: - Profile Management & Settings
    
    public func selectProfile(_ profile: XboxConsoleProfile) {
        if activeProfile.id != profile.id {
            disconnect()
            activeProfile = profile
            saveSettings()
            playHaptic(.click)
        }
    }
    
    public func saveProfile(_ profile: XboxConsoleProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        } else {
            profiles.append(profile)
        }
        if activeProfile.id == profile.id {
            activeProfile = profile
        }
        saveSettings()
    }
    
    public func deleteProfile(id: UUID) {
        guard profiles.count > 1 else { return }
        profiles.removeAll { $0.id == id }
        if activeProfile.id == id, let first = profiles.first {
            activeProfile = first
        }
        saveSettings()
    }
    
    public func toggleTemperatureUnit() {
        isFahrenheit.toggle()
        saveSettings()
        playHaptic(.click)
    }
    
    public func toggleMockMode() {
        disconnect()
        isMockMode.toggle()
        saveSettings()
        playHaptic(.click)
        lastStatusMessage = isMockMode ? "Demo Mode Enabled" : "Live Mode Enabled"
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(encoded, forKey: profilesKey)
        }
        UserDefaults.standard.set(activeProfile.id.uuidString, forKey: activeProfileIdKey)
        UserDefaults.standard.set(isFahrenheit, forKey: isFahrenheitKey)
        UserDefaults.standard.set(isMockMode, forKey: isMockModeKey)
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([XboxConsoleProfile].self, from: data),
           !decoded.isEmpty {
            self.profiles = decoded
        }
        
        if let activeIdStr = UserDefaults.standard.string(forKey: activeProfileIdKey),
           let activeId = UUID(uuidString: activeIdStr),
           let found = profiles.first(where: { $0.id == activeId }) {
            self.activeProfile = found
        } else if let first = profiles.first {
            self.activeProfile = first
        }
        
        self.isFahrenheit = UserDefaults.standard.bool(forKey: isFahrenheitKey)
        self.isMockMode = UserDefaults.standard.bool(forKey: isMockModeKey)
    }
    
    // MARK: - Haptic Feedback Helpers
    
    public enum HapticFeedbackType {
        case click
        case success
        case failure
        case start
        case stop
        case notification
        case directionUp
    }
    
    public func playHaptic(_ type: HapticFeedbackType) {
        #if canImport(WatchKit)
        let device = WKInterfaceDevice.current()
        switch type {
        case .click:
            device.play(.click)
        case .success:
            device.play(.success)
        case .failure:
            device.play(.failure)
        case .start:
            device.play(.start)
        case .stop:
            device.play(.stop)
        case .notification:
            device.play(.notification)
        case .directionUp:
            device.play(.directionUp)
        }
        #endif
    }
}
