import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 4 else {
  fputs("usage: render-svg-icon.swift input.svg output.png size [fillRatio]\n", stderr)
  exit(64)
}

let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[2])
let size = Int(args[3]) ?? 1024
let fillRatio = args.count > 4 ? (Double(args[4]) ?? 0.84) : 0.84

guard let image = NSImage(contentsOf: input) else {
  fputs("Cannot open SVG: \(input.path)\n", stderr)
  exit(65)
}

guard let bitmap = NSBitmapImageRep(
  bitmapDataPlanes: nil,
  pixelsWide: size,
  pixelsHigh: size,
  bitsPerSample: 8,
  samplesPerPixel: 4,
  hasAlpha: true,
  isPlanar: false,
  colorSpaceName: .deviceRGB,
  bytesPerRow: 0,
  bitsPerPixel: 0
) else {
  fputs("Cannot allocate bitmap\n", stderr)
  exit(66)
}

bitmap.size = NSSize(width: size, height: size)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: size, height: size).fill()

let source = image.size
let targetMaxSide = Double(size) * fillRatio
let scale = min(targetMaxSide / source.width, targetMaxSide / source.height)
let width = source.width * scale
let height = source.height * scale
let rect = NSRect(
  x: (Double(size) - width) / 2,
  y: (Double(size) - height) / 2,
  width: width,
  height: height
)

image.draw(
  in: rect,
  from: .zero,
  operation: .sourceOver,
  fraction: 1,
  respectFlipped: true,
  hints: [.interpolation: NSImageInterpolation.high]
)
NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
  fputs("PNG encoding failed\n", stderr)
  exit(67)
}
try png.write(to: output)
