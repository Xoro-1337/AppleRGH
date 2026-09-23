import SwiftUI
import Watch360Core

public struct RingOfLightView: View {
    @EnvironmentObject var manager: XboxToolboxManager
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("RING OF LIGHT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                
                // Visual Xbox 360 Ring of Light Simulator
                ZStack {
                    // Outer Ring Base
                    Circle()
                        .stroke(Color(white: 0.2), lineWidth: 14)
                        .frame(width: 80, height: 80)
                    
                    // Central Power Button Icon
                    Circle()
                        .fill(Color(white: 0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "power")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        )
                    
                    // Quadrant 1: Top-Left (180 to 270 deg)
                    quadrantArc(color: manager.ringOfLight.quadrant1, startAngle: .degrees(185), endAngle: .degrees(265))
                        .onTapGesture {
                            cycleQuadrant(\.quadrant1)
                        }
                    
                    // Quadrant 2: Top-Right (270 to 360/0 deg)
                    quadrantArc(color: manager.ringOfLight.quadrant2, startAngle: .degrees(275), endAngle: .degrees(355))
                        .onTapGesture {
                            cycleQuadrant(\.quadrant2)
                        }
                    
                    // Quadrant 3: Bottom-Left (90 to 180 deg)
                    quadrantArc(color: manager.ringOfLight.quadrant3, startAngle: .degrees(95), endAngle: .degrees(175))
                        .onTapGesture {
                            cycleQuadrant(\.quadrant3)
                        }
                    
                    // Quadrant 4: Bottom-Right (0 to 90 deg)
                    quadrantArc(color: manager.ringOfLight.quadrant4, startAngle: .degrees(5), endAngle: .degrees(85))
                        .onTapGesture {
                            cycleQuadrant(\.quadrant4)
                        }
                }
                .frame(width: 90, height: 90)
                .padding(.vertical, 4)
                
                Text("Tap quadrant to cycle color")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                // Preset Patterns
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        presetButton(title: "P1 Standard", state: .standardPlayer1)
                        presetButton(title: "All Green", state: .allGreen)
                    }
                    HStack(spacing: 6) {
                        presetButton(title: "RRoD Sim", state: .redRingOfDeath, accent: .red)
                        presetButton(title: "All Off", state: .allOff)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("LEDs")
    }
    
    // MARK: - Quadrant Arc
    
    private func quadrantArc(color: RoLLedColor, startAngle: Angle, endAngle: Angle) -> some View {
        Circle()
            .trim(from: CGFloat(startAngle.degrees / 360.0), to: CGFloat(endAngle.degrees / 360.0))
            .stroke(
                uiColor(for: color),
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .frame(width: 80, height: 80)
            .shadow(color: uiColor(for: color).opacity(color == .off ? 0 : 0.8), radius: 4)
    }
    
    private func uiColor(for color: RoLLedColor) -> Color {
        switch color {
        case .off: return Color(white: 0.25)
        case .green: return Color.green
        case .red: return Color.red
        case .orange: return Color.orange
        }
    }
    
    private func cycleQuadrant(_ keyPath: WritableKeyPath<RingOfLightState, RoLLedColor>) {
        var current = manager.ringOfLight
        let currentColor = current[keyPath: keyPath]
        let nextColor: RoLLedColor
        switch currentColor {
        case .off: nextColor = .green
        case .green: nextColor = .orange
        case .orange: nextColor = .red
        case .red: nextColor = .off
        }
        current[keyPath: keyPath] = nextColor
        manager.updateRingOfLight(state: current)
    }
    
    private func presetButton(title: String, state: RingOfLightState, accent: Color = .green) -> some View {
        Button {
            manager.updateRingOfLight(state: state)
        } label: {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(white: 0.15))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
