import SwiftUI
import Watch360Core

public struct TelemetryView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Header Bar: Console Model & °C/°F Unit Switch
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(manager.telemetry.consoleType)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                        Text("Kernel: \(manager.telemetry.kernelVersion)")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Button {
                        manager.toggleTemperatureUnit()
                    } label: {
                        Text(manager.isFahrenheit ? "°F" : "°C")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(white: 0.2))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
                
                // 2x2 Temperature Sensor Grid
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        tempGauge(
                            label: "CPU",
                            tempC: manager.telemetry.cpuTempC,
                            warnC: 65.0,
                            dangerC: 75.0
                        )
                        tempGauge(
                            label: "GPU",
                            tempC: manager.telemetry.gpuTempC,
                            warnC: 68.0,
                            dangerC: 78.0
                        )
                    }
                    
                    HStack(spacing: 6) {
                        tempGauge(
                            label: "EDRAM",
                            tempC: manager.telemetry.edramTempC,
                            warnC: 65.0,
                            dangerC: 75.0
                        )
                        tempGauge(
                            label: "MB",
                            tempC: manager.telemetry.motherboardTempC,
                            warnC: 45.0,
                            dangerC: 55.0
                        )
                    }
                }
                
                // Fan Speed & Current Title
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "fanblades.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.cyan)
                        Text("Fan Speed")
                            .font(.system(size: 11, weight: .medium))
                        Spacer()
                        Text("\(manager.telemetry.fanSpeedPercent)%")
                            .font(.system(size: 11, weight: .bold))
                    }
                    
                    // Fan Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(white: 0.2))
                                .frame(height: 6)
                            Capsule()
                                .fill(Color.cyan)
                                .frame(width: geo.size.width * CGFloat(max(0, min(100, manager.telemetry.fanSpeedPercent))) / 100.0, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Divider().background(Color(white: 0.2)).padding(.vertical, 2)
                    
                    // Running Title
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Active Title")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(manager.telemetry.titleName)
                                .font(.system(size: 11, weight: .bold))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .background(Color(white: 0.12))
                .cornerRadius(8)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Sensors")
    }
    
    // MARK: - Temp Gauge Helper
    
    private func tempGauge(label: String, tempC: Double, warnC: Double, dangerC: Double) -> some View {
        let color: Color = {
            if tempC >= dangerC { return .red }
            if tempC >= warnC { return .orange }
            return .green
        }()
        
        return VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            
            Text(manager.telemetry.formattedTemp(celsius: tempC, isFahrenheit: manager.isFahrenheit))
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(white: 0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
