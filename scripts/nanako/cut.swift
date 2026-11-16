// usage: cut <in.png> <out.png> <top> <bottom>: keeps pixel rows top..<bottom (clamped to the image), full width
import AppKit
let a = CommandLine.arguments
guard a.count == 5, let y0 = Int(a[3]), let y1raw = Int(a[4]) else { FileHandle.standardError.write("usage: cut <in.png> <out.png> <top> <bottom>\n".data(using: .utf8)!); exit(2) }
let rep = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: a[1])))!
let y1 = min(y1raw, rep.pixelsHigh)
guard y0 >= 0, y0 < y1 else { FileHandle.standardError.write("empty range \(y0)..<\(y1) of \(rep.pixelsHigh)\n".data(using: .utf8)!); exit(3) }
let out = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: rep.pixelsWide, pixelsHigh: y1 - y0, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
for y in y0..<y1 { for x in 0..<rep.pixelsWide { out.setColor(rep.colorAt(x: x, y: y)!, atX: x, y: y - y0) } }
try! out.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
