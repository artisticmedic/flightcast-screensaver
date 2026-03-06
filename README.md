# Flightcast Logo Shimmer Screensaver

A premium macOS screensaver for the Flightcast team. Features a subtle grid of Flightcast logo marks with animated purple shimmer lights that pass through the icon strokes — like light catching engraved metal.

 <img width="1713" height="1021" alt="image" src="https://github.com/user-attachments/assets/b148c859-3d08-439f-ad5d-66e58f2ce5f2" />

## Install

1. Download **[Flightcast Logo Shimmer.zip](https://github.com/artisticmedic/flightcast-screensaver/releases/latest/download/Flightcast.Logo.Shimmer.zip)** from [Releases](https://github.com/artisticmedic/flightcast-screensaver/releases)
2. Unzip it
3. Double-click **Flightcast Logo Shimmer.saver** to install it
4. Open **System Settings → Wallpaper → Screen Saver**, scroll to the bottom of the list, and click **See More**
5. Select **Flightcast Logo Shimmer** — macOS will show a security warning asking to delete the file. **Click "Keep File"**
6. Go to **System Settings → Privacy & Security**, scroll down to the warning about "Flightcast Logo Shimmer", and click **Open Anyway**. Confirm the system prompt
7. Go back to **Screen Saver** settings. Select a different screensaver first and click **Preview** (this resets the cache), then re-select **Flightcast Logo Shimmer**
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
