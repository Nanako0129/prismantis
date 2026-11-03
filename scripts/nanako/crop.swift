// usage: crop <in.png> <out.png>: keeps the transcript, from below the Claude Code header to above the prompt's top rule
import AppKit
let a = CommandLine.arguments
let rep = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: a[1])))!
let w = rep.pixelsWide, h = rep.pixelsHigh
func isRule(_ y: Int) -> Bool {
  var lit = 0, n = 0
  for x in stride(from: 20, to: w - 80, by: 4) { n += 1; if rep.colorAt(x: x, y: y)!.brightnessComponent > 0.3 { lit += 1 } }
  return lit * 10 > n * 8
}
var groups: [Int] = []
var last = -10
for y in 120..<h where isRule(y) { if y > last + 3 { groups.append(y) }; last = y }
var bottom = groups.count >= 2 ? groups[groups.count - 2] - 8 : h
let bg = rep.colorAt(x: 2, y: h - 2)!
func blankRow(_ y: Int) -> Bool { for x in stride(from: 0, to: w, by: 3) { let c = rep.colorAt(x: x, y: y)!; if abs(c.brightnessComponent - bg.brightnessComponent) > 0.04 { return false } }; return true }
while bottom > 140 && blankRow(bottom - 1) { bottom -= 1 }
bottom = min(bottom + 12, h)
let top = Int(a.count > 3 ? Int(a[3])! : 70)
let rect = NSRect(x: 0, y: top, width: w, height: bottom - top)
let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: bottom - top, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: out)
NSImage(data: try! Data(contentsOf: URL(fileURLWithPath: a[1])))!.draw(in: NSRect(x: 0, y: 0, width: w, height: bottom - top), from: NSRect(x: 0, y: h - bottom, width: w, height: bottom - top), operation: .copy, fraction: 1)
NSGraphicsContext.restoreGraphicsState()
try! out.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
_ = rect
