import SwiftUI

struct SVGPathShape: Shape {
    let d: String
    let viewBox: CGSize

    func path(in rect: CGRect) -> Path {
        Self.buildPath(d: d, viewBox: viewBox, rect: rect)
    }

    private static func isCommandToken(_ s: String) -> Bool {
        guard s.count == 1, let ch = s.first else { return false }
        return "MmLlHhVvCcSsQqTtAaZz".contains(ch)
    }

    private static func tokenize(_ d: String) -> [String] {
        let pattern = "[MmLlHhVvCcSsQqTtAaZz]|[-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = d as NSString
        let range = NSRange(location: 0, length: ns.length)
        return regex.matches(in: d, range: range).compactMap { m in
            guard let r = Range(m.range, in: d) else { return nil }
            return String(d[r])
        }
    }

    static func buildPath(d: String, viewBox: CGSize, rect: CGRect) -> Path {
        let sx = rect.width / viewBox.width
        let sy = rect.height / viewBox.height
        func t(_ p: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + p.x * sx, y: rect.minY + p.y * sy)
        }

        let normalized = d.replacingOccurrences(of: ",", with: " ")
        let tokens = tokenize(normalized)
        var path = Path()
        var i = 0
        var current = CGPoint.zero
        var subStart = CGPoint.zero

        func readDouble() -> CGFloat {
            guard i < tokens.count else { return 0 }
            let v = Double(tokens[i]) ?? 0
            i += 1
            return CGFloat(v)
        }

        func readPoint() -> CGPoint {
            CGPoint(x: readDouble(), y: readDouble())
        }

        while i < tokens.count {
            let tok = tokens[i]
            if !isCommandToken(tok) {
                i += 1
                continue
            }
            guard let cmd = tok.first else { i += 1; continue }
            i += 1

            switch cmd {
            case "M":
                var p = readPoint()
                current = p
                subStart = p
                path.move(to: t(p))
                while i < tokens.count, !isCommandToken(tokens[i]) {
                    p = readPoint()
                    path.addLine(to: t(p))
                    current = p
                }
            case "L":
                while i < tokens.count, !isCommandToken(tokens[i]) {
                    let p = readPoint()
                    path.addLine(to: t(p))
                    current = p
                }
            case "H":
                while i < tokens.count, !isCommandToken(tokens[i]) {
                    let nx = readDouble()
                    current = CGPoint(x: nx, y: current.y)
                    path.addLine(to: t(current))
                }
            case "V":
                while i < tokens.count, !isCommandToken(tokens[i]) {
                    let ny = readDouble()
                    current = CGPoint(x: current.x, y: ny)
                    path.addLine(to: t(current))
                }
            case "C":
                while i < tokens.count, !isCommandToken(tokens[i]) {
                    let c1 = readPoint()
                    let c2 = readPoint()
                    let end = readPoint()
                    path.addCurve(to: t(end), control1: t(c1), control2: t(c2))
                    current = end
                }
            case "Z", "z":
                path.closeSubpath()
                current = subStart
            default:
                break
            }
        }
        return path
    }
}
