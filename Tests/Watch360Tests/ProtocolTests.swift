import XCTest
@testable import Watch360Core

final class ProtocolTests: XCTestCase {
    
    // MARK: - XBDM Response Parsing
    
    func testXBDMGreetingParsing() {
        let greeting = "201- connected\r\n"
        let response = XBDMResponse.parse(rawString: greeting)
        
        XCTAssertEqual(response.code, 201)
        XCTAssertEqual(response.message, "connected")
        XCTAssertTrue(response.isConnectedGreeting)
        XCTAssertTrue(response.isSuccess)
    }
    
    func testXBDMSuccessParsing() {
        let raw = "200- OK\r\n"
        let response = XBDMResponse.parse(rawString: raw)
        
        XCTAssertEqual(response.code, 200)
        XCTAssertEqual(response.message, "OK")
        XCTAssertTrue(response.isSuccess)
    }
    
    func testXBDMErrorParsing() {
        let raw = "400- syntax error\r\n"
        let response = XBDMResponse.parse(rawString: raw)
        
        XCTAssertEqual(response.code, 400)
        XCTAssertEqual(response.message, "syntax error")
        XCTAssertFalse(response.isSuccess)
    }
    
    // MARK: - XBDM Commands String Formatting
    
    func testXBDMCommandsFormatting() {
        XCTAssertEqual(XBDMCommand.bye.commandString, "bye\r\n")
        XCTAssertEqual(XBDMCommand.reboot(cold: false).commandString, "reboot\r\n")
        XCTAssertEqual(XBDMCommand.reboot(cold: true).commandString, "reboot cold\r\n")
        XCTAssertEqual(XBDMCommand.stop.commandString, "stop\r\n")
        XCTAssertEqual(XBDMCommand.go.commandString, "go\r\n")
        XCTAssertEqual(XBDMCommand.dvdEject.commandString, "dvdeject\r\n")
        XCTAssertEqual(XBDMCommand.title.commandString, "title\r\n")
        XCTAssertEqual(XBDMCommand.boxId.commandString, "boxid\r\n")
        XCTAssertEqual(XBDMCommand.dmVersion.commandString, "dmversion\r\n")
        
        let magicboot = XBDMCommand.magicboot(path: "Hdd:\\Aurora\\Aurora.xex").commandString
        XCTAssertEqual(magicboot, "magicboot title=\"Hdd:\\Aurora\\Aurora.xex\"\r\n")
        
        let getMem = XBDMCommand.getMemory(address: 0x82001000, length: 16).commandString
        XCTAssertEqual(getMem, "getmem addr=0x82001000 length=16\r\n")
        
        let setMem = XBDMCommand.setMemory(address: 0x82001000, hexData: "60000000").commandString
        XCTAssertEqual(setMem, "setmem addr=0x82001000 data=60000000\r\n")
    }
    
    // MARK: - Temperature Conversions & Formatting
    
    func testTemperatureFormatting() {
        let telemetry = ConsoleTelemetry(cpuTempC: 50.0)
        
        let cString = telemetry.formattedTemp(celsius: 50.0, isFahrenheit: false)
        XCTAssertEqual(cString, "50.0°C")
        
        let fString = telemetry.formattedTemp(celsius: 50.0, isFahrenheit: true)
        XCTAssertEqual(fString, "122.0°F")
    }
    
    // MARK: - Ring of Light Logic
    
    func testRingOfLightPresets() {
        let p1 = RingOfLightState.standardPlayer1
        XCTAssertEqual(p1.quadrant1, .green)
        XCTAssertEqual(p1.quadrant2, .off)
        XCTAssertEqual(p1.quadrant3, .off)
        XCTAssertEqual(p1.quadrant4, .off)
        
        let rrod = RingOfLightState.redRingOfDeath
        XCTAssertEqual(rrod.quadrant1, .red)
        XCTAssertEqual(rrod.quadrant2, .off)
        XCTAssertEqual(rrod.quadrant3, .red)
        XCTAssertEqual(rrod.quadrant4, .red)
    }
    
    // MARK: - XNotify Parameters Encoding
    
    func testXNotifyHexEncoding() {
        let msg = "Hello"
        let asciiData = msg.data(using: .ascii)!
        let hex = asciiData.map { String(format: "%02X", $0) }.joined()
        XCTAssertEqual(hex, "48656C6C6F")
        XCTAssertEqual(msg.count, 5)
    }
}
