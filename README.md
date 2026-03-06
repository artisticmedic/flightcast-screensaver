# Flightcast Logo Shimmer Screensaver

A premium macOS screensaver for the Flightcast team. Features a subtle grid of Flightcast logo marks with animated purple shimmer lights that pass through the icon strokes — like light catching engraved metal.

 <img width="1713" height="1021" alt="image" src="https://github.com/user-attachments/assets/b148c859-3d08-439f-ad5d-66e58f2ce5f2" />

## Install

1. Download **[Flightcast Logo Shimmer.zip](https://github.com/artisticmedic/flightcast-screensaver/releases/latest/download/Flightcast.Logo.Shimmer.zip)** from [Releases](https://github.com/artisticmedic/flightcast-screensaver/releases)
2. Unzip it
3. **Remove the macOS quarantine flag** (recommended). Open Terminal and run:
   ```bash
   xattr -cr ~/Downloads/Flightcast\ Logo\ Shimmer.saver
   ```
4. Double-click **Flightcast Logo Shimmer.saver** and click **Install**
5. Go to **System Settings → Wallpaper → Screen Saver** and select **Flightcast Logo Shimmer**

### Troubleshooting: "unidentified developer" warning

Since this isn't signed with an Apple Developer certificate, macOS may block the install. Three ways to fix this:

1. **Terminal (recommended):** Run `xattr -cr ~/Downloads/Flightcast\ Logo\ Shimmer.saver` before installing — this strips the quarantine flag.
2. **Right-click → Open:** Instead of double-clicking, right-click the `.saver` file and choose **Open**. A security dialog will appear — click **Open** to proceed.
3. **System Settings:** After a blocked install attempt, go to **System Settings → Privacy & Security**, scroll down, and click **Open Anyway** next to the blocked file.

## Uninstall

Go to `~/Library/Screen Savers/` and delete `Flightcast Logo Shimmer.saver`.

## Build from Source

Requires macOS 13+ and Xcode Command Line Tools.

```bash
# Compile universal binary (arm64 + x86_64)
swiftc -module-name FlightcastLogoShimmer -emit-library -o arm.dylib \
  -framework ScreenSaver -framework AppKit FlightcastView.swift \
  -target arm64-apple-macos13.0

swiftc -module-name FlightcastLogoShimmer -emit-library -o x86.dylib \
  -framework ScreenSaver -framework AppKit FlightcastView.swift \
  -target x86_64-apple-macos13.0

lipo -create arm.dylib x86.dylib \
  -output "Flightcast Logo Shimmer.saver/Contents/MacOS/FlightcastLogoShimmer"
```

Then double-click the `.saver` to install.

## Details

- 30fps native Core Graphics animation
- Universal binary (Apple Silicon + Intel)
- Pure Swift — no dependencies, no Xcode project needed
- ~56KB packaged
