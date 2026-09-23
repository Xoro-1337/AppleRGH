import Foundation
import Network

public enum TransportError: LocalizedError {
    case connectionFailed(String)
    case notConnected
    case timeout
    case invalidResponse
    case disconnected
    
    public var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .notConnected:
            return "Not connected to console"
        case .timeout:
            return "Request timed out"
        case .invalidResponse:
            return "Invalid response received from console"
        case .disconnected:
            return "Connection was closed by console"
        }
    }
}

/// Actor managing low-level TCP socket communication to the Xbox 360 via Network.framework
public actor NWConnectionTransport {
    private var connection: NWConnection?
    private var isConnected: Bool = false
    private let queue = DispatchQueue(label: "com.watch360.network.transport", qos: .userInitiated)
    
    public init() {}
    
    public var connected: Bool {
        return isConnected
    }
    
    /// Connects to Xbox 360 on the given host and port, awaiting the "201- connected" greeting banner.
    public func connect(host: String, port: Int = 730, timeoutSeconds: Double = 5.0) async throws -> String {
        disconnect()
        
        let nwHost = NWEndpoint.Host(host)
        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(port)) else {
            throw TransportError.connectionFailed("Invalid port: \(port)")
        }
        
        let tcpOptions = NWProtocolTCP.Options()
        tcpOptions.connectionTimeout = Int(timeoutSeconds)
        tcpOptions.enableKeepalive = true
        tcpOptions.keepaliveIdle = 10
        
        let params = NWParameters(tls: nil, tcp: tcpOptions)
        params.allowLocalEndpointReuse = true
        
        let conn = NWConnection(host: nwHost, port: nwPort, using: params)
        self.connection = conn
        
        // Wait for connection to transition to ready state
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var resumed = false
            
            conn.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if !resumed {
                        resumed = true
                        continuation.resume()
                    }
                case .failed(let err):
                    if !resumed {
                        resumed = true
                        continuation.resume(throwing: TransportError.connectionFailed(err.localizedDescription))
                    }
                case .cancelled:
                    if !resumed {
                        resumed = true
                        continuation.resume(throwing: TransportError.disconnected)
                    }
                case .waiting(let err):
                    // In local network, waiting can indicate unreachable host
                    if !resumed && (err == .posix(.ENETUNREACH) || err == .posix(.EHOSTUNREACH)) {
                        resumed = true
                        continuation.resume(throwing: TransportError.connectionFailed("Host unreachable"))
                    }
                default:
                    break
                }
            }
            
            conn.start(queue: self.queue)
        }
        
        self.isConnected = true
        
        // Receive the initial XBDM greeting (typically "201- connected\r\n")
        let greeting = try await receiveLine(timeoutSeconds: timeoutSeconds)
        return greeting
    }
    
    /// Sends a command string and awaits the response
    public func send(command: String, timeoutSeconds: Double = 4.0) async throws -> String {
        guard isConnected, let conn = connection else {
            throw TransportError.notConnected
        }
        
        let data = Data(command.utf8)
        
        // Send data
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            conn.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    continuation.resume(throwing: TransportError.connectionFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            })
        }
        
        // Receive line response
        return try await receiveLine(timeoutSeconds: timeoutSeconds)
    }
    
    /// Receives a line of text up to \r\n or \n
    private func receiveLine(timeoutSeconds: Double) async throws -> String {
        guard let conn = connection else {
            throw TransportError.notConnected
        }
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    var accumulatedData = Data()
                    
                    func readNextChunk() {
                        conn.receive(minimumIncompleteLength: 1, maximumLength: 2048) { data, _, isComplete, error in
                            if let error = error {
                                continuation.resume(throwing: TransportError.connectionFailed(error.localizedDescription))
                                return
                            }
                            
                            if let data = data, !data.isEmpty {
                                accumulatedData.append(data)
                                
                                if let string = String(data: accumulatedData, encoding: .ascii) ?? String(data: accumulatedData, encoding: .utf8) {
                                    // Check if we hit end of line or complete response
                                    if string.contains("\r\n") || string.contains("\n") {
                                        continuation.resume(returning: string)
                                        return
                                    }
                                }
                            }
                            
                            if isComplete {
                                let finalString = String(data: accumulatedData, encoding: .ascii) ?? ""
                                continuation.resume(returning: finalString)
                            } else {
                                readNextChunk()
                            }
                        }
                    }
                    
                    readNextChunk()
                }
            }
            
            // Timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                throw TransportError.timeout
            }
            
            guard let result = try await group.next() else {
                throw TransportError.timeout
            }
            group.cancelAll()
            return result
        }
    }
    
    /// Closes socket connection
    public func disconnect() {
        isConnected = false
        connection?.cancel()
        connection = nil
    }
}
