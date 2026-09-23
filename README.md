# Watch360 - Apple Watch RGH/JTAG Xbox 360 Toolbox

<p align="center">
  <strong>Control, monitor, and mod your RGH/JTAG Xbox 360 directly from your Apple Watch!</strong>
</p>

---

## 🌟 Overview

**Watch360** brings traditional desktop Xbox 360 toolboxes (like Xbox 360 Neighborhood, XDCKIT, and JRPC tools) right to your wrist on watchOS. Communicating directly over local Wi-Fi via raw TCP sockets (`Network.framework`), the app connects to port **730** on your console to interact with **XBDM** (`xbdm.xex`) and **JRPC2** (`jrpc2.xex`).

### ✨ Core Features

* ⚡ **Power & Execution Controls**:
  * Warm Reboot (reboot current title or dashboard)
  * Cold Reboot (hard system reboot)
  * System Shutdown (power down console)
  * Freeze / Unfreeze thread execution (instant game pause/resume)
  * Open / Close DVD drive tray
* 🌡️ **Live Hardware Telemetry**:
  * Real-time thermal gauges for **CPU**, **GPU**, **EDRAM**, and **Motherboard**
  * Color-coded safety thresholds (Green < 65°C, Orange 65–75°C, Red > 75°C)
  * Dynamic Fan Speed gauge (0–100%)
  * Console Motherboard revision detection (Trinity, Corona, Jasper, Falcon, etc.)
  * Active Dashboard / Kernel version display
  * Switch between **Celsius (°C)** and **Fahrenheit (°F)**
* 🔔 **XNotify Toast Broadcaster**:
  * Send custom notifications directly to the Xbox 360 TV HUD
  * Type via Apple Watch dictation, Scribble, or keyboard
  * Choose from 20+ authentic HUD icons (Xbox Logo, Trophy, Friend Request, Game Invite, Hammer, Music, etc.)
  * 1-tap quick presets: *"Dinner Ready!"*, *"Game Invite"*, *"10 Mins Left"*, *"BRB"*, *"Watch Connected"*
* 🚀 **Dashboard & Title Launcher**:
  * Quick-launch buttons for **Stock Dashboard**, **Aurora**, **Freestyle 3**, and **XEXMenu**
  * Custom XEX path execution (e.g. `Hdd:\Games\Halo 3\default.xex`)
  * Live Active Title ID & Name display
* 🟢 **Interactive Ring of Light (RoL) Controller**:
  * Visual 4-quadrant LED simulator on watchOS
  * Tap individual quadrants to cycle through **Off**, **Green**, **Orange**, and **Red**
  * Preset animations and modes: Standard Player 1, All Green, 3-Red-Light (RRoD) simulation, and Stealth Off
* 🎮 **Remote & Memory Tools**:
  * Xbox Guide button shortcut trigger
  * Virtual D-Pad controller (Up, Down, Left, Right, A button)
  * Memory Peek & Poke engine (read/write arbitrary memory offsets and cheats in real-time)
* ⚙️ **Console Profiles & Demo Mode**:
  * Multi-console management with custom nicknames, IPs, and ports
  * Built-in **Demo / Mock Mode** with simulated thermal jitter and response mocks for testing in the Xcode Watch Simulator without needing a physical Xbox nearby!

---

## 🛠️ Xbox 360 Setup Requirements

To connect your Apple Watch to your Xbox 360, your console must be modified with **RGH** (Reset Glitch Hack) or **JTAG**, running **DashLaunch** with the debug monitor plugins loaded.

### 1. `launch.ini` Plugin Configuration

Ensure your `launch.ini` file (located on the root of `Hdd:\` or `Usb:\`) includes `xbdm.xex` and `jrpc2.xex`:

```ini
[Plugins]
plugin1 = Hdd:\plugins\xbdm.xex
plugin2 = Hdd:\plugins\jrpc2.xex
```

> [!NOTE]
> - `xbdm.xex` provides the base Xbox Debug Monitor protocol on TCP port **730**.
> - `jrpc2.xex` provides the `consolefeatures ver=2` RPC extension used for thermal sensors, XNotify toasts with custom logos, and Ring of Light controls.
> - If only `xbdm.xex` is present, core toolbox functions (Reboot, Shutdown, Freeze, Tray, Title, Memory Peek/Poke) will still work natively.

### 2. Network Configuration

1. Connect your Xbox 360 to your home Wi-Fi/Ethernet network.
2. Find your console's IP address (e.g. in Aurora, DashLaunch, or Network Settings: `192.168.1.150`).
3. Ensure your Apple Watch is connected to the same local Wi-Fi subnet.

---

## 📱 Building & Deploying to Apple Watch

### Requirements:
* Mac running macOS 13+ with **Xcode 15+**
* Apple Watch running **watchOS 9.0+** (or Xcode Watch Simulator)

### Option A: Open with Swift Package Manager (Recommended)
1. Double-click or open `Package.swift` in Xcode:
   ```bash
   xed .
   ```
2. Select the `Watch360` scheme and your Apple Watch (or watchOS Simulator) as the target.
3. Click **Run (⌘R)**.

### Option B: Generate Xcode Project via XcodeGen
If you prefer a standalone `.xcodeproj`:
```bash
# Install xcodegen if not already installed (brew install xcodegen)
xcodegen generate
open Watch360.xcodeproj
```

---

## 🔒 Permissions & Security Notes

* **Local Network Privacy**: The app declares `NSLocalNetworkUsageDescription` in `Info.plist` to allow raw socket communication over the local subnet. When first connecting, watchOS will prompt: *"Allow Watch360 to find and connect to devices on your local network"*. Tap **Allow**.
* **Offline Console Use**: XBDM and JRPC are intended for offline homebrew consoles or private stealth networks. Do not connect to official Xbox Live servers with debug monitor plugins active.

---

## 🧪 Unit Testing

Unit tests for XBDM protocol lines, response parsing, temperature conversions, and XNotify hex formatting can be run via:

```bash
swift test
```

---

## 📄 License

GPL-3.0 License. Designed for homebrew development, diagnostics, and console management.
