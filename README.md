# Flightcast Logo Shimmer Screensaver

A premium macOS screensaver for the Flightcast team. Features a subtle grid of Flightcast logo marks with animated purple shimmer lights that pass through the icon strokes — like light catching engraved metal.

 <img width="1713" height="1021" alt="image" src="https://github.com/user-attachments/assets/b148c859-3d08-439f-ad5d-66e58f2ce5f2" />

## Install

1. Download **[Flightcast Logo Shimmer.zip](https://github.com/doac-stuff/flightcast-screensaver/releases/latest/download/Flightcast.Logo.Shimmer.zip)** from [Releases](https://github.com/doac-stuff/flightcast-screensaver/releases)
2. Unzip it
3. Double-click **Flightcast Logo Shimmer.saver**
4. macOS will ask if you want to install — click **Install**
5. Go to **System Settings → Screen Saver** and select **Flightcast Logo Shimmer**

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
