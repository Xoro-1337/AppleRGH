import Foundation

public actor XBDMClient {
    private let transport: NWConnectionTransport
    
    public init(transport: NWConnectionTransport = NWConnectionTransport()) {
        self.transport = transport
    }
    
    public var isConnected: Bool {
        get async {
            await transport.connected
        }
    }
    
    /// Connect to the Xbox 360 XBDM server
    @discardableResult
    public func connect(host: String, port: Int = 730) async throws -> XBDMResponse {
        let greetingRaw = try await transport.connect(host: host, port: port)
        return XBDMResponse.parse(rawString: greetingRaw)
    }
    
    /// Disconnects from the console
    public func disconnect() async {
        do {
            _ = try await transport.send(command: XBDMCommand.bye.commandString, timeoutSeconds: 1.0)
        } catch {
            // Ignore disconnect errors
        }
        await transport.disconnect()
    }
    
    /// Send any XBDMCommand and parse response
    public func execute(_ command: XBDMCommand) async throws -> XBDMResponse {
        let rawResponse = try await transport.send(command: command.commandString)
        return XBDMResponse.parse(rawString: rawResponse)
    }
    
    /// Reboot the console (warm or cold)
    public func reboot(cold: Bool = false) async throws -> XBDMResponse {
        return try await execute(.reboot(cold: cold))
    }
    
    /// Shutdown the console
    public func shutdown() async throws -> XBDMResponse {
        return try await execute(.shutdown)
    }
    
    /// Freeze console threads
    public func freeze() async throws -> XBDMResponse {
        return try await execute(.stop)
    }
    
    /// Resume console threads
    public func unfreeze() async throws -> XBDMResponse {
        return try await execute(.go)
    }
    
    /// Eject or close DVD drive tray
    public func ejectTray() async throws -> XBDMResponse {
        return try await execute(.dvdEject)
    }
    
    /// Query current running title
    public func getTitleInfo() async throws -> RunningTitleInfo {
        let response = try await execute(.title)
        // Response format example: "200- name="dash.xex" dir="""
        var titleName = "Unknown"
        if let nameRange = response.raw.range(of: "name=\"") {
            let substring = response.raw[nameRange.upperBound...]
            if let endRange = substring.range(of: "\"") {
                titleName = String(substring[..<endRange.lowerBound])
            }
        }
        
        return RunningTitleInfo(titleId: "00000000", name: titleName)
    }
    
    /// Launch an XEX executable file
    public func launchTitle(path: String) async throws -> XBDMResponse {
        return try await execute(.magicboot(path: path))
    }
    
    /// Get Box ID
    public func getBoxId() async throws -> String {
        let resp = try await execute(.boxId)
        return resp.message
    }
    
    /// Get XBDM Version
    public func getDmVersion() async throws -> String {
        let resp = try await execute(.dmVersion)
        return resp.message
    }
    
    /// Peek/Read memory at address
    public func getMemory(address: UInt32, length: Int) async throws -> String {
        let resp = try await execute(.getMemory(address: address, length: length))
        return resp.message
    }
    
    /// Poke/Write memory at address
    public func setMemory(address: UInt32, hexData: String) async throws -> XBDMResponse {
        return try await execute(.setMemory(address: address, hexData: hexData))
    }
    
    /// Send raw string command
    public func sendRaw(_ command: String) async throws -> XBDMResponse {
        return try await execute(.raw(command))
    }
}
