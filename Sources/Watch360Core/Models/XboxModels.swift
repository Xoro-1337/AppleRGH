import Foundation

// MARK: - Console Connection Profile
public struct XboxConsoleProfile: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var ipAddress: String
    public var port: Int
    public var isDefault: Bool
    
    public init(id: UUID = UUID(), name: String, ipAddress: String, port: Int = 730, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.port = port
        self.isDefault = isDefault
    }
    
    public static let `default` = XboxConsoleProfile(
        name: "My Xbox 360",
        ipAddress: "192.168.1.100",
        port: 730,
        isDefault: true
    )
}

// MARK: - Running Title Info
public struct RunningTitleInfo: Equatable, Codable {
    public let titleId: String
    public let name: String
    
    public init(titleId: String = "00000000", name: String = "Dashboard") {
        self.titleId = titleId
        self.name = name
    }
}

// MARK: - Hardware Temperatures
public struct HardwareTemperatures: Equatable, Codable {
    public let cpu: Double
    public let gpu: Double
    public let edram: Double
    public let motherboard: Double
    
    public init(cpu: Double, gpu: Double, edram: Double, motherboard: Double) {
        self.cpu = cpu
        self.gpu = gpu
        self.edram = edram
        self.motherboard = motherboard
    }
}

// MARK: - Hardware Telemetry
public struct ConsoleTelemetry: Equatable, Codable {
    public var cpuTempC: Double
    public var gpuTempC: Double
    public var edramTempC: Double
    public var motherboardTempC: Double
    public var fanSpeedPercent: Int
    public var kernelVersion: String
    public var consoleType: String
    public var titleId: String
    public var titleName: String
    public var lastUpdated: Date
    
    public init(
        cpuTempC: Double = 0.0,
        gpuTempC: Double = 0.0,
        edramTempC: Double = 0.0,
        motherboardTempC: Double = 0.0,
        fanSpeedPercent: Int = 0,
        kernelVersion: String = "Unknown",
        consoleType: String = "RGH / JTAG",
        titleId: String = "00000000",
        titleName: String = "Dashboard",
        lastUpdated: Date = Date()
    ) {
        self.cpuTempC = cpuTempC
        self.gpuTempC = gpuTempC
        self.edramTempC = edramTempC
        self.motherboardTempC = motherboardTempC
        self.fanSpeedPercent = fanSpeedPercent
        self.kernelVersion = kernelVersion
        self.consoleType = consoleType
        self.titleId = titleId
        self.titleName = titleName
        self.lastUpdated = lastUpdated
    }
    
    public func formattedTemp(celsius: Double, isFahrenheit: Bool) -> String {
        if isFahrenheit {
            let f = (celsius * 9.0 / 5.0) + 32.0
            return String(format: "%.1f°F", f)
        } else {
            return String(format: "%.1f°C", celsius)
        }
    }
    
    public static let sample = ConsoleTelemetry(
        cpuTempC: 54.2,
        gpuTempC: 61.8,
        edramTempC: 58.0,
        motherboardTempC: 39.5,
        fanSpeedPercent: 45,
        kernelVersion: "2.0.17559.0",
        consoleType: "Corona (Slim)",
        titleId: "FFFE07D1",
        titleName: "Xbox Dashboard",
        lastUpdated: Date()
    )
}

// MARK: - XNotify Icons & Logos
public enum XNotifyLogo: Int, CaseIterable, Identifiable, Codable {
    case xboxLogo = 0
    case newMessageLogo = 1
    case friendRequestLogo = 2
    case newMessage = 3
    case flashingXboxLogo = 4
    case gamertagSentMessage = 5
    case gamertagSignedOut = 6
    case gamertagSignedIn = 7
    case gamertagSignedIntoLive = 8
    case disconnectedFromLive = 11
    case download = 12
    case flashingMusic = 13
    case flashingHappyFace = 14
    case flashingFrowningFace = 15
    case flashingHammer = 16
    case gameInviteSent = 22
    case flashLogo = 23
    case achievementUnlocked = 27
    case readyToPlay = 31
    case flashingXboxConsole = 34
    case partyInviteSent = 50
    case joinedLiveParty = 61
    case updating = 76
    
    public var id: Int { rawValue }
    
    public var displayName: String {
        switch self {
        case .xboxLogo: return "Xbox Logo"
        case .flashingXboxLogo: return "Pulse Xbox"
        case .achievementUnlocked: return "Achievement"
        case .friendRequestLogo: return "Friend Req"
        case .gameInviteSent: return "Game Invite"
        case .partyInviteSent: return "Party Invite"
        case .newMessageLogo: return "Message"
        case .flashingHammer: return "Hammer"
        case .flashingHappyFace: return "Happy Face"
        case .flashingFrowningFace: return "Frown Face"
        case .flashingMusic: return "Music Note"
        case .readyToPlay: return "Ready to Play"
        case .download: return "Download"
        case .flashingXboxConsole: return "Console"
        default: return "Logo #\(rawValue)"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .xboxLogo, .flashingXboxLogo, .flashingXboxConsole:
            return "gamecontroller.fill"
        case .achievementUnlocked:
            return "trophy.fill"
        case .friendRequestLogo:
            return "person.crop.circle.badge.plus"
        case .gameInviteSent, .partyInviteSent:
            return "person.2.fill"
        case .newMessageLogo, .newMessage, .gamertagSentMessage:
            return "message.fill"
        case .flashingHammer:
            return "hammer.fill"
        case .flashingHappyFace:
            return "face.smiling.fill"
        case .flashingFrowningFace:
            return "face.dashed.fill"
        case .flashingMusic:
            return "music.note"
        case .download:
            return "arrow.down.circle.fill"
        case .readyToPlay:
            return "play.circle.fill"
        default:
            return "bell.fill"
        }
    }
}

// MARK: - XNotify Preset Message
public struct XNotifyPreset: Identifiable, Hashable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let logo: XNotifyLogo
    
    public init(title: String, message: String, logo: XNotifyLogo) {
        self.title = title
        self.message = message
        self.logo = logo
    }
    
    public static let defaults: [XNotifyPreset] = [
        XNotifyPreset(title: "Watch Connected", message: "Apple Watch Connected!", logo: .flashingXboxLogo),
        XNotifyPreset(title: "Dinner Ready", message: "Dinner is ready! Save and quit.", logo: .newMessageLogo),
        XNotifyPreset(title: "Game Invite", message: "Join my lobby now!", logo: .gameInviteSent),
        XNotifyPreset(title: "10 Mins Left", message: "10 minutes remaining on timer.", logo: .flashingHammer),
        XNotifyPreset(title: "Achievement", message: "Secret Achievement Unlocked (0G)", logo: .achievementUnlocked),
        XNotifyPreset(title: "BRB", message: "Stepping away for a minute...", logo: .readyToPlay)
    ]
}

// MARK: - Ring of Light (RoL)
public enum RoLLedColor: Int, CaseIterable, Codable {
    case off = 0
    case green = 1
    case red = 2
    case orange = 3
    
    public var displayName: String {
        switch self {
        case .off: return "Off"
        case .green: return "Green"
        case .red: return "Red"
        case .orange: return "Orange"
        }
    }
}

public struct RingOfLightState: Equatable, Codable {
    public var quadrant1: RoLLedColor // Top-Left
    public var quadrant2: RoLLedColor // Top-Right
    public var quadrant3: RoLLedColor // Bottom-Left
    public var quadrant4: RoLLedColor // Bottom-Right
    
    public init(
        quadrant1: RoLLedColor = .green,
        quadrant2: RoLLedColor = .off,
        quadrant3: RoLLedColor = .off,
        quadrant4: RoLLedColor = .off
    ) {
        self.quadrant1 = quadrant1
        self.quadrant2 = quadrant2
        self.quadrant3 = quadrant3
        self.quadrant4 = quadrant4
    }
    
    public static let standardPlayer1 = RingOfLightState(quadrant1: .green, quadrant2: .off, quadrant3: .off, quadrant4: .off)
    public static let allGreen = RingOfLightState(quadrant1: .green, quadrant2: .green, quadrant3: .green, quadrant4: .green)
    public static let allOff = RingOfLightState(quadrant1: .off, quadrant2: .off, quadrant3: .off, quadrant4: .off)
    public static let redRingOfDeath = RingOfLightState(quadrant1: .red, quadrant2: .off, quadrant3: .red, quadrant4: .red) // 3 red lights
    public static let allOrange = RingOfLightState(quadrant1: .orange, quadrant2: .orange, quadrant3: .orange, quadrant4: .orange)
}

// MARK: - Power Actions
public enum PowerAction: String, CaseIterable, Identifiable {
    case warmReboot = "Reboot (Warm)"
    case coldReboot = "Reboot (Cold)"
    case shutdown = "Shutdown"
    case stop = "Freeze"
    case go = "Unfreeze"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .warmReboot: return "arrow.clockwise.circle.fill"
        case .coldReboot: return "bolt.circle.fill"
        case .shutdown: return "power.circle.fill"
        case .stop: return "pause.circle.fill"
        case .go: return "play.circle.fill"
        }
    }
}

// MARK: - Quick Launch Dashboard & XEX
public struct QuickLaunchTitle: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let xexPath: String
    public let iconName: String
    
    public init(name: String, xexPath: String, iconName: String) {
        self.name = name
        self.xexPath = xexPath
        self.iconName = iconName
    }
    
    public static let defaults: [QuickLaunchTitle] = [
        QuickLaunchTitle(name: "Stock Dashboard", xexPath: "flash:\\dash.xex", iconName: "house.fill"),
        QuickLaunchTitle(name: "Aurora", xexPath: "Hdd:\\Aurora\\Aurora.xex", iconName: "sparkles"),
        QuickLaunchTitle(name: "Freestyle 3", xexPath: "Hdd:\\Freestyle\\default.xex", iconName: "square.grid.2x2.fill"),
        QuickLaunchTitle(name: "XEXMenu", xexPath: "Hdd:\\Content\\0000000000000000\\C0DE9999\\00080000\\c0de99990f580000", iconName: "folder.fill")
    ]
}

// MARK: - Memory Peek / Poke Item
public struct MemoryQuickPoke: Identifiable, Hashable {
    public let id = UUID()
    public let label: String
    public let address: UInt32
    public let writeBytes: [UInt8]
    public let revertBytes: [UInt8]
    public var isApplied: Bool
    
    public init(label: String, address: UInt32, writeBytes: [UInt8], revertBytes: [UInt8], isApplied: Bool = false) {
        self.label = label
        self.address = address
        self.writeBytes = writeBytes
        self.revertBytes = revertBytes
        self.isApplied = isApplied
    }
    
    public var addressHex: String {
        String(format: "0x%08X", address)
    }
    
    public var dataHex: String {
        writeBytes.map { String(format: "%02X", $0) }.joined()
    }
}
