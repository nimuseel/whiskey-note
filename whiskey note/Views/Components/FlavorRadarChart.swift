import SwiftUI

struct FlavorRadarChart: View {
    struct Item {
        let label: String
        let emoji: String
        let intensity: Int
    }

    let items: [Item]
    let maxIntensity: Int = 5
    let levels: Int = 5

    var body: some View {
        GeometryReader { geo in
            let size      = min(geo.size.width, geo.size.height)
            let center    = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let chartR    = size * 0.34
            let labelR    = size * 0.47
            let n         = items.count

            ZStack {
                // ── 격자 & 축선 ──────────────────────────────
                Canvas { ctx, _ in
                    // 배경 다각형 (레벨별)
                    for level in 1...levels {
                        let ratio = Double(level) / Double(levels)
                        let path  = polygonPath(center: center, radius: chartR * ratio, n: n)
                        if level == levels {
                            ctx.fill(path, with: .color(AppColors.accent.opacity(0.06)))
                        }
                        ctx.stroke(path, with: .color(AppColors.accent.opacity(0.18)), lineWidth: 1)
                    }

                    // 축선
                    for i in 0..<n {
                        let θ = theta(i: i, n: n)
                        var axis = Path()
                        axis.move(to: center)
                        axis.addLine(to: polarPoint(center: center, r: chartR, θ: θ))
                        ctx.stroke(axis, with: .color(AppColors.accent.opacity(0.25)), lineWidth: 1)
                    }

                    // ── 데이터 다각형 ────────────────────────
                    guard items.contains(where: { $0.intensity > 0 }) else { return }

                    let dataPath = dataPoly(center: center, radius: chartR, n: n)
                    ctx.fill(dataPath, with: .color(AppColors.accent.opacity(0.28)))
                    ctx.stroke(dataPath, with: .color(AppColors.accent.opacity(0.85)), lineWidth: 2)

                    // 꼭짓점 점
                    for i in 0..<n {
                        let ratio = Double(items[i].intensity) / Double(maxIntensity)
                        let pt    = polarPoint(center: center, r: chartR * ratio, θ: theta(i: i, n: n))
                        let dot   = Path(ellipseIn: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8))
                        ctx.fill(dot, with: .color(AppColors.accent))
                    }
                }

                // ── 레이블 ───────────────────────────────────
                ForEach(0..<n, id: \.self) { i in
                    let pt   = polarPoint(center: center, r: labelR, θ: theta(i: i, n: n))
                    let item = items[i]
                    VStack(spacing: 1) {
                        Text(item.emoji)
                            .font(.system(size: 15))
                        Text(NSLocalizedString(item.label, comment: ""))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                    .position(x: pt.x, y: pt.y)
                }
            }
        }
    }

    // MARK: - Math

    private func theta(i: Int, n: Int) -> Double {
        2 * .pi * Double(i) / Double(n) - .pi / 2
    }

    private func polarPoint(center: CGPoint, r: Double, θ: Double) -> CGPoint {
        CGPoint(x: center.x + r * cos(θ), y: center.y + r * sin(θ))
    }

    private func polygonPath(center: CGPoint, radius: Double, n: Int) -> Path {
        var path = Path()
        for i in 0..<n {
            let pt = polarPoint(center: center, r: radius, θ: theta(i: i, n: n))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }

    private func dataPoly(center: CGPoint, radius: Double, n: Int) -> Path {
        var path = Path()
        for i in 0..<n {
            let ratio = Double(items[i].intensity) / Double(maxIntensity)
            let pt    = polarPoint(center: center, r: radius * ratio, θ: theta(i: i, n: n))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}
