import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var notes: [WhiskeyNote]

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "기록이 쌓이면 통계가 표시됩니다.",
                        systemImage: "chart.bar"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            topAromaChart
                            categoryDistribution
                            ratingDistribution
                        }
                        .padding()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("통계")
        }
    }

    // MARK: - Top Aroma Chart

    private var topAromaData: [(name: String, emoji: String, avg: Double)] {
        var sums: [String: Int] = [:]
        var counts: [String: Int] = [:]
        for note in notes {
            for fi in note.flavorIntensities
                where fi.flavorType == FlavorType.aroma.rawValue && fi.intensity > 0 {
                sums[fi.name, default: 0] += fi.intensity
                counts[fi.name, default: 0] += 1
            }
        }
        return sums
            .map { name, sum -> (name: String, emoji: String, avg: Double) in
                let emoji = FlavorConstants.all.first { $0.name == name }?.emoji ?? ""
                return (name: name, emoji: emoji, avg: Double(sum) / Double(counts[name]!))
            }
            .sorted { $0.avg > $1.avg }
            .prefix(5)
            .map { $0 }
    }

    private var topAromaChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("선호 향 TOP 5")
                .font(.headline)
                .foregroundStyle(AppColors.accent)

            if topAromaData.isEmpty {
                Text("향 데이터가 없어요.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                let maxAvg = topAromaData.first?.avg ?? 1
                ForEach(topAromaData, id: \.name) { item in
                    HStack(spacing: 8) {
                        Text("\(item.emoji) \(NSLocalizedString(item.name, comment: ""))")
                            .font(.subheadline)
                            .frame(width: 90, alignment: .leading)
                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.accent)
                                .frame(width: geo.size.width * (item.avg / maxAvg), height: 12)
                        }
                        .frame(height: 12)
                        Text(String(format: "%.1f", item.avg))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 28, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Distribution

    private var categoryCounts: [(category: String, count: Int, pct: Double)] {
        var counts: [String: Int] = [:]
        for note in notes { counts[note.category, default: 0] += 1 }
        let total = Double(notes.count)
        return counts
            .map { (category: $0.key, count: $0.value, pct: Double($0.value) / total * 100) }
            .sorted { $0.count > $1.count }
    }

    private var categoryDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리 분포")
                .font(.headline)
                .foregroundStyle(AppColors.accent)
            FlowLayout(spacing: 8) {
                ForEach(categoryCounts, id: \.category) { item in
                    Text("\(WhiskeyCategory(rawValue: item.category)?.localizedName ?? item.category) \(Int(item.pct.rounded()))%")
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.tagBackground)
                        .foregroundStyle(AppColors.accent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Rating Distribution

    private var ratingBuckets: [(label: String, count: Int)] {
        let buckets: [Double] = stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
        return buckets.compactMap { value in
            let count = notes.filter { $0.rating == value }.count
            return count > 0 ? (label: String(format: "%.1f", value), count: count) : nil
        }
    }

    private var ratingDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("별점 분포")
                .font(.headline)
                .foregroundStyle(AppColors.accent)
            if ratingBuckets.isEmpty {
                Text("별점 데이터가 없어요.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                let maxCount = ratingBuckets.map { $0.count }.max() ?? 1
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(ratingBuckets, id: \.label) { bucket in
                        VStack(spacing: 4) {
                            Text("\(bucket.count)")
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.accent)
                                .frame(height: CGFloat(bucket.count) / CGFloat(maxCount) * 60)
                            Text(bucket.label)
                                .font(.caption2)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > width && x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
            rowH = max(rowH, s.height); x += s.width + spacing
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX; var y = bounds.minY; var rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX && x > bounds.minX { y += rowH + spacing; x = bounds.minX; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            rowH = max(rowH, s.height); x += s.width + spacing
        }
    }
}
