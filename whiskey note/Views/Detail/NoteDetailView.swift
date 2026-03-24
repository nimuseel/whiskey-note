import SwiftUI
import SwiftData

struct NoteDetailView: View {
    let note: WhiskeyNote

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var showWizard = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private let priceFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 사진
                if let data = note.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 16) {
                    basicInfoSection
                    Divider()
                    StarRatingView(rating: .constant(note.rating), isEditable: false)
                    Text(Self.dateFormatter.string(from: note.createdAt))
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Divider()
                    flavorSections

                    if !note.memo.isEmpty {
                        Divider()
                        sectionHeader("메모")
                        Text(note.memo)
                            .font(.body)
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    if !note.dish.isEmpty {
                        Divider()
                        sectionHeader("같이 먹은 안주")
                        Text(note.dish)
                            .font(.body)
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("노트 삭제", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(note.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("수정") { showWizard = true }
            }
        }
        .fullScreenCover(isPresented: $showWizard) {
            NoteWizardView(existingNote: note)
        }
        .alert("정말 삭제할까요?", isPresented: $showDeleteAlert) {
            Button("삭제", role: .destructive) {
                modelContext.delete(note)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.name)
                .font(.title2.bold())
                .foregroundStyle(AppColors.textPrimary)
            HStack(spacing: 4) {
                Text(WhiskeyCategory(rawValue: note.category)?.localizedName ?? note.category)
                if let age = note.age { Text("· \(age)yr") }
                if let abv = note.abv { Text(String(format: "· %.1f%%", abv)) }
                if let price = note.price,
                   let formatted = priceFormatter.string(from: NSNumber(value: price)) {
                    Text("· " + (Locale.current.language.languageCode?.identifier == "ko" ? "\(formatted)원" : "$\(formatted)"))
                }
            }
            .font(.subheadline)
            .foregroundStyle(AppColors.accent)
        }
    }

    @ViewBuilder
    private var flavorSections: some View {
        let sections: [(title: String, type: FlavorType)] = [
            ("향 (Aroma)", .aroma), ("맛 (Taste)", .taste),
            ("질감 (Mouthfeel)", .mouthfeel), ("마무리 (Finish)", .finish)
        ]
        ForEach(sections, id: \.title) { section in
            let items = note.flavorIntensities
                .filter { $0.flavorType == section.type.rawValue && $0.intensity > 0 }
                .sorted { $0.intensity > $1.intensity }
            if !items.isEmpty {
                sectionHeader(LocalizedStringKey(section.title))
                ForEach(items, id: \.id) { fi in
                    if let flavorItem = FlavorConstants.all.first(where: { $0.name == fi.name }) {
                        HStack {
                            Text("\(flavorItem.emoji) \(NSLocalizedString(fi.name, comment: ""))")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            HStack(spacing: 3) {
                                ForEach(1...5, id: \.self) { i in
                                    Circle()
                                        .fill(i <= fi.intensity ? AppColors.accent : AppColors.tagBackground)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                }
                Divider()
            }
        }
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppColors.accent)
    }
}
