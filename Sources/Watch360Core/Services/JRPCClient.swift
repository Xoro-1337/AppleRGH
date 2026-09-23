import Foundation

public actor JRPCClient {
    private let transport: NWConnectionTransport
    
    public init(transport: NWConnectionTransport = NWConnectionTransport()) {
        self.transport = transport
    }
    
    public var isConnected: Bool {
        get async {
            await transport.connected
        }
    }
    
    /// Connects to Xbox 360 JRPC server
    @discardableResult
    public func connect(host: String, port: Int = 730) async throws -> XBDMResponse {
        let raw = try await transport.connect(host: host, port: port)
        return XBDMResponse.parse(rawString: raw)
    }
    
    /// Disconnects from console
    public func disconnect() async {
        await transport.disconnect()
    }
    
    /// Sends an XNotify toast notification to the Xbox 360 HUD
    /// - Parameters:
    ///   - message: Text message to display
    ///   - logo: Icon / logo to display with the toast
    @discardableResult
    public func sendXNotify(message: String, logo: XNotifyLogo = .xboxLogo) async throws -> XBDMResponse {
        // Truncate to reasonable max length (e.g. 64 chars)
        let safeMessage = String(message.prefix(64))
        guard let messageData = safeMessage.data(using: .isoLatin1) ?? safeMessage.data(using: .utf8) else {
            throw TransportError.invalidResponse
        }
        
        let hexString = messageData.map { String(format: "%02X", $0) }.joined()
        let length = safeMessage.count
        let command = "consolefeatures ver=2 type=12 params=\"A\\0\\A\\2\\2/\(length)\\\(hexString)\\1\\\(logo.rawValue)\\\"\r\n"
        
        let raw = try await transport.send(command: command)
        return XBDMResponse.parse(rawString: raw)
    }
    
    /// Query console hardware temperatures (CPU, GPU, EDRAM, Motherboard)
    public func getTemperatures() async throws -> HardwareTemperatures {
        let command = "consolefeatures ver=2 type=2\r\n"
        let raw = try await transport.send(command: command)
        let response = XBDMResponse.parse(rawString: raw)
        
        guard response.isSuccess else {
            throw TransportError.invalidResponse
        }
        
        return parseTemperatureResponse(response.message)
    }
    
    /// Query console kernel version
    public func getKernelVersion() async throws -> String {
        let command = "consolefeatures ver=2 type=13\r\n"
        let raw = try await transport.send(command: command)
        let response = XBDMResponse.parse(rawString: raw)
        
        if response.isSuccess && !response.message.isEmpty {
            return response.message.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "Unknown"
    }
    
    /// Query console motherboard / hardware revision
    public func getConsoleType() async throws -> String {
        let command = "consolefeatures ver=2 type=1\r\n"
        let raw = try await transport.send(command: command)
        let response = XBDMResponse.parse(rawString: raw)
        
        if response.isSuccess && !response.message.isEmpty {
            let msg = response.message.trimmingCharacters(in: .whitespacesAndNewlines)
            return parseConsoleTypeString(msg)
        }
        return "Xbox 360 (RGH/JTAG)"
    }
    
    /// Set Ring of Light (RoL) quadrant LED colors
    @discardableResult
    public func setRingOfLight(state: RingOfLightState) async throws -> XBDMResponse {
        let q1 = state.quadrant1.rawValue
        let q2 = state.quadrant2.rawValue
        let q3 = state.quadrant3.rawValue
        let q4 = state.quadrant4.rawValue
        
        let command = "consolefeatures ver=2 type=14 params=\"A\\0\\A\\4\\1\\\(q1)\\1\\\(q2)\\1\\\(q3)\\1\\\(q4)\\\"\r\n"
        let raw = try await transport.send(command: command)
        return XBDMResponse.parse(rawString: raw)
    }
    
    /// Power / Reboot command through JRPC (0=Title, 1=Cold, 2=Warm, 3=Shutdown)
    @discardableResult
    public func powerAction(_ action: Int) async throws -> XBDMResponse {
        let command = "consolefeatures ver=2 type=3 params=\"A\\0\\A\\1\\1\\\(action)\\\"\r\n"
        let raw = try await transport.send(command: command)
        return XBDMResponse.parse(rawString: raw)
    }
    
    /// DVD Tray Control (0=Open, 1=Close)
    @discardableResult
    public func setTray(open: Bool) async throws -> XBDMResponse {
        let val = open ? 0 : 1
        let command = "consolefeatures ver=2 type=15 params=\"A\\0\\A\\1\\1\\\(val)\\\"\r\n"
        let raw = try await transport.send(command: command)
        return XBDMResponse.parse(rawString: raw)
    }
    
    // MARK: - Parsers
    
    private func parseTemperatureResponse(_ text: String) -> HardwareTemperatures {
        // Formats handled:
        // 1. "CPU:54.2 GPU:61.8 EDRAM:58.0 MB:39.5"
        // 2. "54.2,61.8,58.0,39.5" or hex formatted values
        // 3. "CPU=54.2,GPU=61.8,..."
        var cpu = 50.0
        var gpu = 55.0
        var edram = 52.0
        var mb = 35.0
        
        let cleaned = text.replacingOccurrences(of: "\"", with: "")
        
        // Try key-value format
        let parts = cleaned.components(separatedBy: CharacterSet(charactersIn: " ,;\t"))
        for part in parts {
            let kv = part.split(separator: ":", maxSplits: 1).map(String.init)
            let kvAlt = part.split(separator: "=", maxSplits: 1).map(String.init)
            let pair = kv.count == 2 ? kv : (kvAlt.count == 2 ? kvAlt : [])
            
            if pair.count == 2 {
                let key = pair[0].uppercased()
                if let val = Double(pair[1].trimmingCharacters(in: .letters)) {
                    if key.contains("CPU") { cpu = val }
                    else if key.contains("GPU") { gpu = val }
                    else if key.contains("EDRAM") || key.contains("MEM") { edram = val }
                    else if key.contains("MB") || key.contains("BOARD") || key.contains("CHASSIS") { mb = val }
                }
            }
        }
        
        // If no key-values found, try raw numbers separated by commas or spaces
        if cpu == 50.0 && gpu == 55.0 {
            let numbers = cleaned.components(separatedBy: CharacterSet(charactersIn: " ,/|"))
                .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            if numbers.count >= 4 {
                cpu = numbers[0]
                gpu = numbers[1]
                edram = numbers[2]
                mb = numbers[3]
            }
        }
        
        return HardwareTemperatures(cpu: cpu, gpu: gpu, edram: edram, motherboard: mb)
    }
    
    private func parseConsoleTypeString(_ raw: String) -> String {
        let upper = raw.uppercased()
        if upper.contains("CORONA") { return "Corona (Slim)" }
        if upper.contains("TRINITY") { return "Trinity (Slim)" }
        if upper.contains("JASPER") { return "Jasper (Phat)" }
        if upper.contains("FALCON") { return "Falcon (Phat)" }
        if upper.contains("ZEPHYR") { return "Zephyr (Phat)" }
        if upper.contains("XENON") { return "Xenon (Phat)" }
        if upper.contains("WINCHESTER") { return "Winchester (Slim E)" }
        if upper.contains("DEVKIT") { return "Xbox 360 DevKit" }
        return raw.isEmpty ? "Xbox 360 RGH" : raw
    }
}
