import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \WhiskeyNote.createdAt, order: .reverse) private var notes: [WhiskeyNote]
    @State private var showWizard = false

    private var recentNotes: [WhiskeyNote] { Array(notes.prefix(5)) }

    private var averageRating: String {
        let rated = notes.filter { $0.rating > 0 }
        guard !rated.isEmpty else { return "-" }
        let avg = rated.map { $0.rating }.reduce(0, +) / Double(rated.count)
        return String(format: "%.1f", avg)
    }

    private var topAromaName: String {
        var sums: [String: Int] = [:]
        for note in notes {
            for fi in note.flavorIntensities where fi.flavorType == FlavorType.aroma.rawValue {
                sums[fi.name, default: 0] += fi.intensity
            }
        }
        guard !sums.isEmpty else { return "-" }
        let sorted = sums.sorted { lhs, rhs in
            if lhs.value != rhs.value { return lhs.value > rhs.value }
            let li = FlavorConstants.all.firstIndex { $0.name == lhs.key } ?? 999
            let ri = FlavorConstants.all.firstIndex { $0.name == rhs.key } ?? 999
            return li < ri
        }
        let name = sorted.first!.key
        let emoji = FlavorConstants.all.first { $0.name == name }?.emoji ?? ""
        let localizedName = NSLocalizedString(name, comment: "")
        return "\(emoji) \(localizedName)"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if notes.isEmpty {
                        ContentUnavailableView(
                            "아직 기록이 없어요.",
                            systemImage: "wineglass",
                            description: Text("아래 + 버튼으로 첫 노트를 추가해보세요!")
                        )
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                profileCard
                                recentSection
                            }
                            .padding()
                            .padding(.bottom, 80)
                        }
                    }
                }
                .background(AppColors.background.ignoresSafeArea())

                // FAB
                Button { showWizard = true } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(AppColors.accent)
                        .clipShape(Circle())
                        .shadow(radius: 4, y: 2)
                }
                .accessibilityIdentifier("fab")
                .padding(20)
            }
            .navigationTitle("위스키 노트")
            .fullScreenCover(isPresented: $showWizard) { NoteWizardView() }
        }
    }

    private var profileCard: some View {
        HStack(spacing: 0) {
            statCell(label: "기록", value: "\(notes.count)")
            Divider().frame(height: 40)
            statCell(label: "평균 별점", value: averageRating)
            Divider().frame(height: 40)
            statCell(label: "대표 향", value: topAromaName)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private func statCell(label: LocalizedStringKey, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).foregroundStyle(AppColors.textPrimary)
            Text(label).font(.caption).foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("최근 기록")
                .font(.headline)
                .foregroundStyle(AppColors.accent)

            ForEach(recentNotes) { note in
                NavigationLink(value: note) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(AppColors.textPrimary)
                            StarRatingView(rating: .constant(note.rating), isEditable: false, starSize: 12)
                        }
                        Spacer()
                        Text(note.createdAt, format: .dateTime.month().day())
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .navigationDestination(for: WhiskeyNote.self) { note in
            NoteDetailView(note: note)
        }
    }
}
