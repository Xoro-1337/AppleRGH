import Foundation

// MARK: - XBDM Response
public struct XBDMResponse: Equatable {
    public let code: Int
    public let message: String
    public let lines: [String]
    public let raw: String
    
    public var isSuccess: Bool {
        return (200...299).contains(code)
    }
    
    public var isConnectedGreeting: Bool {
        return code == 201
    }
    
    public var isMultiline: Bool {
        return code == 202
    }
    
    public var isBinary: Bool {
        return code == 203
    }
    
    public init(code: Int, message: String, lines: [String] = [], raw: String) {
        self.code = code
        self.message = message
        self.lines = lines
        self.raw = raw
    }
    
    /// Parses an XBDM single-line or multi-line response
    public static func parse(rawString: String) -> XBDMResponse {
        let trimmed = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = rawString.components(separatedBy: "\r\n").filter { !$0.isEmpty }
        
        guard let firstLine = lines.first ?? trimmed.components(separatedBy: "\n").first else {
            return XBDMResponse(code: 0, message: "Empty response", lines: [], raw: rawString)
        }
        
        // Typical format: "200- OK" or "201- connected" or "400- syntax error"
        if firstLine.count >= 4,
           let parsedCode = Int(firstLine.prefix(3)),
           firstLine[firstLine.index(firstLine.startIndex, offsetBy: 3)] == "-" {
            let msgStart = firstLine.index(firstLine.startIndex, offsetBy: 4)
            let msg = String(firstLine[msgStart...]).trimmingCharacters(in: .whitespaces)
            return XBDMResponse(code: parsedCode, message: msg, lines: lines, raw: rawString)
        }
        
        return XBDMResponse(code: 200, message: trimmed, lines: lines, raw: rawString)
    }
}

// MARK: - Standard XBDM Commands
public enum XBDMCommand {
    case bye
    case reboot(cold: Bool)
    case shutdown
    case stop
    case go
    case dvdEject
    case title
    case magicboot(path: String)
    case getMemory(address: UInt32, length: Int)
    case setMemory(address: UInt32, hexData: String)
    case boxId
    case dmVersion
    case driveFreeSpace(drive: String)
    case driveList
    case raw(String)
    
    public var commandString: String {
        switch self {
        case .bye:
            return "bye\r\n"
        case .reboot(let cold):
            return cold ? "reboot cold\r\n" : "reboot\r\n"
        case .shutdown:
            return "magicbox_shutdown\r\n"
        case .stop:
            return "stop\r\n"
        case .go:
            return "go\r\n"
        case .dvdEject:
            return "dvdeject\r\n"
        case .title:
            return "title\r\n"
        case .magicboot(let path):
            return "magicboot title=\"\(path)\"\r\n"
        case .getMemory(let address, let length):
            return String(format: "getmem addr=0x%X length=%d\r\n", address, length)
        case .setMemory(let address, let hexData):
            return String(format: "setmem addr=0x%X data=%@\r\n", address, hexData)
        case .boxId:
            return "boxid\r\n"
        case .dmVersion:
            return "dmversion\r\n"
        case .driveFreeSpace(let drive):
            return "drivefreespace name=\"\(drive)\"\r\n"
        case .driveList:
            return "drivelist\r\n"
        case .raw(let cmd):
            if cmd.hasSuffix("\r\n") {
                return cmd
            } else {
                return cmd + "\r\n"
            }
        }
    }
}
