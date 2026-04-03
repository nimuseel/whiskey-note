import SwiftUI

// MARK: - Card Colors (카드 전용 다크 테마)

private enum CardColors {
    static let backgroundStart = Color(red: 0.118, green: 0.071, blue: 0.031) // #1e1208
    static let backgroundEnd   = Color(red: 0.227, green: 0.141, blue: 0.055) // #3a200e
    static let amber           = Color(red: 0.910, green: 0.659, blue: 0.220) // #e8a838
    static let accentBar       = Color(red: 0.608, green: 0.416, blue: 0.184) // #9b6a2f
    static let tagBg           = Color(red: 0.608, green: 0.416, blue: 0.184).opacity(0.25)
    static let tagBorder       = Color(red: 0.608, green: 0.416, blue: 0.184).opacity(0.35)
    static let textPrimary     = Color.white
    static let textSecondary   = Color.white.opacity(0.45)
    static let textTertiary    = Color.white.opacity(0.25)
    static let starEmpty       = Color.white.opacity(0.12)
    static let watermark       = Color.white.opacity(0.18)
}

// MARK: - ShareCardView

struct ShareCardView: View {
    let note: WhiskeyNote
    let tastingNumber: Int

    private var topAromaItems: [(item: FlavorItem, intensity: Int)] {
        ShareCardHelper.topAromaItems(from: note, limit: 3)
    }
    private var radarValues: [Double] {
        ShareCardHelper.radarAxisValues(from: note)
    }
    private var hasMemo: Bool { !note.memo.isEmpty }
    private var hasFlavor: Bool { ShareCardHelper.hasAnyFlavor(from: note) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CardColors.backgroundStart, CardColors.backgroundEnd],
                startPoint: UnitPoint(x: 0.1, y: 0),
                endPoint: UnitPoint(x: 0.9, y: 1)
            )

            VStack(alignment: .leading, spacing: 0) {
                // 뱃지
                Text("TASTING #\(tastingNumber)")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(CardColors.amber.opacity(0.7))
                    .padding(.bottom, 10)

                // 위스키 이름
                Text(note.name)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(CardColors.textPrimary)
                    .lineLimit(2)
                    .padding(.bottom, 3)

                // 카테고리 · 도수
                subtitleView
                    .padding(.bottom, 14)

                // 점수 블록
                if note.rating > 0 {
                    scoreView
                        .padding(.bottom, 14)
                }

                // 메인 영역
                mainAreaView
                    .padding(.bottom, 14)

                Spacer(minLength: 0)

                // 향미 태그
                if !topAromaItems.isEmpty {
                    tagsView
                        .padding(.bottom, 10)
                }

                // 워터마크
                HStack {
                    Spacer()
                    Text("whiskey-note.app")
                        .font(.system(size: 9))
                        .tracking(0.5)
                        .foregroundStyle(CardColors.watermark)
                }
            }
            .padding(24)
        }
        .frame(width: 360, height: 360)
    }

    // MARK: - Subtitle

    private var subtitleView: some View {
        var parts: [String] = []
        if let category = WhiskeyCategory(rawValue: note.category) {
            parts.append(category.localizedName)
        }
        if let abv = note.abv {
            parts.append(String(format: "%.1f%%", abv))
        }
        return Text(parts.joined(separator: " · "))
            .font(.system(size: 10))
            .foregroundStyle(CardColors.textSecondary)
    }

    // MARK: - Score

    private var scoreView: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(String(format: "%.1f", note.rating))
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(CardColors.amber)

            VStack(alignment: .leading, spacing: 3) {
                ShareStarRow(rating: note.rating)
                Text("out of 5.0")
                    .font(.system(size: 8))
                    .foregroundStyle(CardColors.textTertiary)
            }
        }
    }

    // MARK: - Main Area

    @ViewBuilder
    private var mainAreaView: some View {
        if hasMemo {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(CardColors.accentBar)
                    .frame(width: 2)
                    .padding(.trailing, 10)
                Text("\"\(note.memo)\"")
                    .font(.system(size: 12, weight: .regular).italic())
                    .foregroundStyle(CardColors.textPrimary.opacity(0.8))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else if hasFlavor {
            ShareRadarChart(axisValues: radarValues)
                .frame(width: 100, height: 100)
        }
    }

    // MARK: - Tags

    private var tagsView: some View {
        HStack(spacing: 5) {
            ForEach(topAromaItems, id: \.item.name) { entry in
                Text("\(entry.item.emoji) \(entry.item.name)")
                    .font(.system(size: 9))
                    .foregroundStyle(CardColors.amber)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(CardColors.tagBg)
                    .overlay(Capsule().stroke(CardColors.tagBorder, lineWidth: 1))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - ShareStarRow

private struct ShareStarRow: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                starImage(for: index)
                    .font(.system(size: 11))
            }
        }
    }

    private func starImage(for index: Int) -> some View {
        let filled = rating >= Double(index) + 1.0
        let half   = rating >= Double(index) + 0.5
        let name   = filled ? "star.fill" : (half ? "star.leadinghalf.filled" : "star")
        return Image(systemName: name)
            .foregroundStyle(filled || half ? CardColors.amber : CardColors.starEmpty)
    }
}

// MARK: - ShareRadarChart (4축: 향·맛·질감·마무리)

private struct ShareRadarChart: View {
    /// [aroma, taste, mouthfeel, finish] 순서, 각 0.0~5.0
    let axisValues: [Double]
    private let labels = ["향", "맛", "질감", "마무리"]
    private let maxValue: Double = 5.0
    private let levels = 3

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let chartR = size * 0.33
            let labelR = size * 0.47
            let n      = 4

            ZStack {
                Canvas { ctx, _ in
                    for level in 1...levels {
                        let ratio = Double(level) / Double(levels)
                        let path  = polygon(center: center, r: chartR * ratio, n: n)
                        ctx.stroke(path, with: .color(.white.opacity(0.1)), lineWidth: 1)
                    }
                    for i in 0..<n {
                        var axis = Path()
                        axis.move(to: center)
                        axis.addLine(to: polar(center: center, r: chartR, θ: angle(i: i, n: n)))
                        ctx.stroke(axis, with: .color(.white.opacity(0.1)), lineWidth: 1)
                    }
                    guard axisValues.contains(where: { $0 > 0 }) else { return }
                    let dataPath = dataPolygon(center: center, r: chartR, n: n)
                    ctx.fill(dataPath, with: .color(Color(red: 0.608, green: 0.416, blue: 0.184).opacity(0.35)))
                    ctx.stroke(dataPath, with: .color(Color(red: 0.910, green: 0.659, blue: 0.220).opacity(0.9)), lineWidth: 1.5)
                }

                ForEach(0..<n, id: \.self) { i in
                    let pt = polar(center: center, r: labelR, θ: angle(i: i, n: n))
                    Text(labels[i])
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .position(x: pt.x, y: pt.y)
                }
            }
        }
    }

    private func angle(i: Int, n: Int) -> Double {
        2 * .pi * Double(i) / Double(n) - .pi / 2
    }

    private func polar(center: CGPoint, r: Double, θ: Double) -> CGPoint {
        CGPoint(x: center.x + r * cos(θ), y: center.y + r * sin(θ))
    }

    private func polygon(center: CGPoint, r: Double, n: Int) -> Path {
        var path = Path()
        for i in 0..<n {
            let pt = polar(center: center, r: r, θ: angle(i: i, n: n))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }

    private func dataPolygon(center: CGPoint, r: Double, n: Int) -> Path {
        var path = Path()
        for i in 0..<n {
            let ratio = (axisValues.indices.contains(i) ? axisValues[i] : 0) / maxValue
            let pt = polar(center: center, r: r * ratio, θ: angle(i: i, n: n))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview("메모 있음") {
    let note = WhiskeyNote(name: "Glenfarclas 25Y")
    note.category = WhiskeyCategory.singleMalt.rawValue
    note.abv = 43.0
    note.rating = 4.5
    note.memo = "달콤한 셰리향과 긴 여운, 지금까지 마신 것 중 최고"
    note.flavorIntensities = [
        FlavorIntensity(flavorType: .aroma, name: "과일", intensity: 5),
        FlavorIntensity(flavorType: .aroma, name: "와인", intensity: 4),
        FlavorIntensity(flavorType: .aroma, name: "견과류", intensity: 3),
        FlavorIntensity(flavorType: .taste, name: "단맛", intensity: 4),
        FlavorIntensity(flavorType: .mouthfeel, name: "부드러움", intensity: 5),
        FlavorIntensity(flavorType: .finish, name: "긴", intensity: 4),
    ]
    return ShareCardView(note: note, tastingNumber: 47)
}

#Preview("메모 없음 - 레이더 차트") {
    let note = WhiskeyNote(name: "Laphroaig 10Y")
    note.category = WhiskeyCategory.singleMalt.rawValue
    note.abv = 40.0
    note.rating = 4.0
    note.flavorIntensities = [
        FlavorIntensity(flavorType: .aroma, name: "피트", intensity: 5),
        FlavorIntensity(flavorType: .aroma, name: "과일", intensity: 2),
        FlavorIntensity(flavorType: .taste, name: "짠맛", intensity: 4),
        FlavorIntensity(flavorType: .mouthfeel, name: "오일", intensity: 3),
        FlavorIntensity(flavorType: .finish, name: "긴", intensity: 5),
    ]
    return ShareCardView(note: note, tastingNumber: 12)
}
