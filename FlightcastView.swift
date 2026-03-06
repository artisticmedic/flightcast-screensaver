import ScreenSaver

class FlightcastView: ScreenSaverView {

    private let bgColor = NSColor(red: 0.024, green: 0.024, blue: 0.059, alpha: 1.0)
    private let iconSize: CGFloat = 24
    private let cellSize: CGFloat = 72
    private var startTime: TimeInterval = 0

    private var gridImage: CGImage?
    private var cachedSize: NSSize = .zero
    private var wordmarkImage: CGImage?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1.0 / 30.0
        startTime = Date.timeIntervalSinceReferenceDate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        animationTimeInterval = 1.0 / 30.0
        startTime = Date.timeIntervalSinceReferenceDate
    }

    // Logo path flipped for macOS bottom-left origin (28 - y for each point)
    private func logoMarkPath() -> CGPath {
        let path = CGMutablePath()
        let h: CGFloat = 28
        // Vertical line
        path.move(to: CGPoint(x: 14.0208, y: h - 1.92755))
        path.addLine(to: CGPoint(x: 14.0003, y: h - 25.6665))
        // Left wing
        path.move(to: CGPoint(x: 13.9019, y: h - 1.8999))
        path.addLine(to: CGPoint(x: 3.38368, y: h - 17.9553))
        path.addCurve(to: CGPoint(x: 3.87714, y: h - 20.0838),
                      control1: CGPoint(x: 2.90453, y: h - 18.6741),
                      control2: CGPoint(x: 3.13098, y: h - 19.6486))
        path.addLine(to: CGPoint(x: 13.8546, y: h - 26.1647))
        // Right wing
        path.move(to: CGPoint(x: 14.099, y: h - 1.8999))
        path.addLine(to: CGPoint(x: 24.6578, y: h - 17.9553))
        path.addCurve(to: CGPoint(x: 24.1654, y: h - 20.0831),
                      control1: CGPoint(x: 25.1369, y: h - 18.6741),
                      control2: CGPoint(x: 24.9116, y: h - 19.6479))
        path.addLine(to: CGPoint(x: 14.1405, y: h - 26.1647))
        return path
    }

    private func rebuildCache() {
        let w = bounds.width
        let h = bounds.height
        guard w > 0 && h > 0 else { return }
        cachedSize = bounds.size

        let scale = iconSize / 28.0
        let cols = Int(ceil(w / cellSize)) + 2
        let rows = Int(ceil(h / cellSize)) + 2
        let gridW = CGFloat(cols) * cellSize
        let gridH = CGFloat(rows) * cellSize
        let startX = (w - gridW) / 2 + (cellSize - iconSize) / 2
        let startY = (h - gridH) / 2 + (cellSize - iconSize) / 2

        let logo = logoMarkPath()
        let bw = Int(w)
        let bh = Int(h)

        // Render grid to bitmap (no coordinate flip needed — native bottom-left)
        guard let gridCtx = CGContext(data: nil, width: bw, height: bh,
                                       bitsPerComponent: 8, bytesPerRow: 0,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }

        gridCtx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        gridCtx.setLineWidth(1.71429 * scale)
        gridCtx.setLineCap(.round)
        gridCtx.setLineJoin(.round)

        for row in 0..<rows {
            for col in 0..<cols {
                let x = startX + CGFloat(col) * cellSize
                let y = startY + CGFloat(row) * cellSize
                gridCtx.saveGState()
                gridCtx.translateBy(x: x, y: y)
                gridCtx.scaleBy(x: scale, y: scale)
                gridCtx.addPath(logo)
                gridCtx.strokePath()
                gridCtx.restoreGState()
            }
        }
        gridImage = gridCtx.makeImage()

        // Render wordmark — smaller overall, mark scaled to match text cap height
        let wmRenderScale: CGFloat = 2.0  // render at 2x for crispness
        let fontSize: CGFloat = 9.75  // 25% smaller than V14's 13
        let font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        let text = "Flightcast" as NSString
        let textSize = text.size(withAttributes: attrs)
        let markH: CGFloat = textSize.height  // mark matches full text line height
        let markScale = markH / 28.0
        let markW: CGFloat = 28.0 * markScale
        let gap: CGFloat = 6.0
        let totalW = markW + gap + textSize.width
        let totalH = max(markH, textSize.height) + 4

        let wmW = Int(totalW * wmRenderScale) + 4
        let wmH = Int(totalH * wmRenderScale) + 4
        guard let wmCtx = CGContext(data: nil, width: wmW, height: wmH,
                                     bitsPerComponent: 8, bytesPerRow: 0,
                                     space: CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }

        wmCtx.translateBy(x: 2, y: 2)
        wmCtx.scaleBy(x: wmRenderScale, y: wmRenderScale)

        // Draw mark icon scaled to match text
        let markY = (totalH - markH) / 2
        wmCtx.saveGState()
        wmCtx.translateBy(x: 0, y: markY)
        wmCtx.scaleBy(x: markScale, y: markScale)
        wmCtx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        wmCtx.setLineWidth(1.71429)
        wmCtx.setLineCap(.round)
        wmCtx.setLineJoin(.round)
        wmCtx.addPath(logoMarkPath())
        wmCtx.strokePath()
        wmCtx.restoreGState()

        // Draw "Flightcast" text
        wmCtx.saveGState()
        wmCtx.translateBy(x: 0, y: totalH)
        wmCtx.scaleBy(x: 1, y: -1)
        let nsGfx = NSGraphicsContext(cgContext: wmCtx, flipped: true)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsGfx
        let textY = (totalH - textSize.height) / 2
        text.draw(at: NSPoint(x: markW + gap, y: textY), withAttributes: attrs)
        NSGraphicsContext.restoreGraphicsState()
        wmCtx.restoreGState()

        wordmarkImage = wmCtx.makeImage()
    }

    override func draw(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        let w = bounds.width
        let h = bounds.height
        let time = Date.timeIntervalSinceReferenceDate - startTime

        if cachedSize != bounds.size {
            rebuildCache()
        }

        // NO coordinate flip — everything in native macOS bottom-left origin

        // Background
        ctx.setFillColor(bgColor.cgColor)
        ctx.fill(bounds)

        // Draw base grid at very low opacity (barely visible when not lit)
        if let img = gridImage {
            ctx.setAlpha(0.010)
            ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
            ctx.setAlpha(1.0)
        }

        // Shimmer lights (positions in screen coords, origin bottom-left)
        let bw = Int(w)
        let bh = Int(h)

        guard let shimCtx = CGContext(data: nil, width: bw, height: bh,
                                      bitsPerComponent: 8, bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }

        struct LightDef {
            var speedX: Double; var speedY: Double; var phase: Double
            var radius: CGFloat; var r: CGFloat; var g: CGFloat; var b: CGFloat; var intensity: Double
        }

        let defs: [LightDef] = [
            // V3 colors/sizes — first light ~12x faster than V3's 0.013 (~42s full sweep)
            LightDef(speedX: 0.15, speedY: 0.07, phase: 0, radius: 0.22,
                     r: 126/255, g: 85/255, b: 216/255, intensity: 1.0),
            LightDef(speedX: -0.010, speedY: 0.0072, phase: 2.2, radius: 0.3,
                     r: 100/255, g: 58/255, b: 255/255, intensity: 0.8),
            LightDef(speedX: 0.007, speedY: -0.0096, phase: 4.5, radius: 0.25,
                     r: 160/255, g: 130/255, b: 255/255, intensity: 0.7),
        ]

        for (i, def) in defs.enumerated() {
            let sinX = CGFloat(sin(time * def.speedX + def.phase))
            let cx = w * (0.5 + 0.45 * sinX)
            let cy = h * (0.5 + 0.4 * CGFloat(cos(time * def.speedY + def.phase + 1.5)))
            let r = min(w, h) * def.radius
            let pulse = 0.6 + 0.4 * sin(time * 0.12 + def.phase)
            // First light fades in/out as it sweeps — bright at edges, dark at center
            let sweepFade: CGFloat = i == 0 ? abs(sinX) : 1.0
            let alpha = CGFloat(def.intensity * pulse) * sweepFade

            let colors: [CGColor] = [
                CGColor(red: def.r, green: def.g, blue: def.b, alpha: alpha),
                CGColor(red: def.r, green: def.g, blue: def.b, alpha: alpha * 0.4),
                CGColor(red: def.r, green: def.g, blue: def.b, alpha: 0)
            ]
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray, locations: [0, 0.4, 1.0]) {
                shimCtx.drawRadialGradient(grad,
                                           startCenter: CGPoint(x: cx, y: cy), startRadius: 0,
                                           endCenter: CGPoint(x: cx, y: cy), endRadius: r, options: [])
            }
        }

        // Streak 1
        let sp1 = fmod(time / 55.0, 1.0)
        let sx1 = w * CGFloat(sp1 * 1.6 - 0.3)
        let sy1 = h * CGFloat(1.0 - (sp1 * 1.4 - 0.2))  // flip Y for bottom-left
        let sa1 = CGFloat(0.5 * sin(sp1 * .pi))
        if sa1 > 0.01 {
            let colors: [CGColor] = [
                CGColor(red: 220/255, green: 200/255, blue: 1, alpha: sa1),
                CGColor(red: 180/255, green: 160/255, blue: 1, alpha: sa1 * 0.3),
                CGColor(red: 180/255, green: 160/255, blue: 1, alpha: 0)
            ]
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray, locations: [0, 0.3, 1.0]) {
                shimCtx.drawRadialGradient(grad,
                                           startCenter: CGPoint(x: sx1, y: sy1), startRadius: 0,
                                           endCenter: CGPoint(x: sx1, y: sy1), endRadius: w * 0.18, options: [])
            }
        }

        // Streak 2
        let sp2 = fmod((time + 28) / 70.0, 1.0)
        let sx2 = w * CGFloat(1.0 - (sp2 * 1.6 - 0.3))
        let sy2 = h * CGFloat(1.0 - (sp2 * 1.3 - 0.15))
        let sa2 = CGFloat(0.35 * sin(sp2 * .pi))
        if sa2 > 0.01 {
            let colors: [CGColor] = [
                CGColor(red: 140/255, green: 100/255, blue: 240/255, alpha: sa2),
                CGColor(red: 120/255, green: 80/255, blue: 220/255, alpha: sa2 * 0.3),
                CGColor(red: 120/255, green: 80/255, blue: 220/255, alpha: 0)
            ]
            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray, locations: [0, 0.3, 1.0]) {
                shimCtx.drawRadialGradient(grad,
                                           startCenter: CGPoint(x: sx2, y: sy2), startRadius: 0,
                                           endCenter: CGPoint(x: sx2, y: sy2), endRadius: w * 0.14, options: [])
            }
        }

        // Mask shimmer through grid strokes
        if let gridImg = gridImage {
            shimCtx.setBlendMode(.destinationIn)
            shimCtx.draw(gridImg, in: CGRect(x: 0, y: 0, width: bw, height: bh))
        }

        if let shimmerImage = shimCtx.makeImage() {
            ctx.draw(shimmerImage, in: CGRect(x: 0, y: 0, width: w, height: h))
        }

        // Vignette
        let vc: [CGColor] = [
            CGColor(red: 0, green: 0, blue: 0, alpha: 0),
            CGColor(red: 0, green: 0, blue: 0, alpha: 0),
            CGColor(red: 0.024, green: 0.024, blue: 0.059, alpha: 0.7)
        ]
        if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: vc as CFArray, locations: [0, 0.3, 1.0]) {
            ctx.drawRadialGradient(grad,
                                   startCenter: CGPoint(x: w/2, y: h/2), startRadius: 0,
                                   endCenter: CGPoint(x: w/2, y: h/2), endRadius: sqrt(w*w+h*h)/2,
                                   options: [])
        }

        // Wordmark bottom-right (in bottom-left origin, bottom-right means low Y, high X)
        if let wmImg = wordmarkImage {
            let wmW = CGFloat(wmImg.width)
            let wmH = CGFloat(wmImg.height)
            ctx.setAlpha(0.12)
            ctx.draw(wmImg, in: CGRect(x: w - wmW - 56, y: 48, width: wmW, height: wmH))
            ctx.setAlpha(1.0)
        }
    }

    override func animateOneFrame() {
        setNeedsDisplay(bounds)
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }
}
