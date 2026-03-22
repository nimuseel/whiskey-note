import SwiftUI

struct NoteCardView: View {
    let note: WhiskeyNote

    private var topAromaTags: [FlavorIntensity] {
        let aromaItems = note.flavorIntensities
            .filter { $0.flavorType == FlavorType.aroma.rawValue && $0.intensity > 0 }
        let sorted = aromaItems.sorted { lhs, rhs in
            if lhs.intensity != rhs.intensity { return lhs.intensity > rhs.intensity }
            let lhsIdx = FlavorConstants.all.firstIndex(where: { $0.name == lhs.name }) ?? 999
            let rhsIdx = FlavorConstants.all.firstIndex(where: { $0.name == rhs.name }) ?? 999
            return lhsIdx < rhsIdx
        }
        return Array(sorted.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(note.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                StarRatingView(rating: .constant(note.rating), isEditable: false, starSize: 14)
            }

            HStack(spacing: 4) {
                Text(note.category)
                if let abv = note.abv {
                    Text("·")
                    Text(String(format: "%.1f%%", abv))
                }
                if let age = note.age {
                    Text("·")
                    Text("\(age)yr")
                }
            }
            .font(.caption)
            .foregroundStyle(AppColors.accent)

            if !topAromaTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(topAromaTags, id: \.id) { fi in
                        if let item = FlavorConstants.all.first(where: { $0.name == fi.name }) {
                            Text("\(item.emoji) \(fi.name)")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.tagBackground)
                                .foregroundStyle(AppColors.accent)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
