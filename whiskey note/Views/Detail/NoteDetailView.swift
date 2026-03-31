import SwiftUI
import SwiftData

struct NoteDetailView: View {
    let note: WhiskeyNote

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("flavorDisplayMode") private var savedFlavorMode: String = FlavorDisplayMode.chart.rawValue
    @State private var showDeleteAlert = false
    @State private var showWizard = false
    @State private var flavorMode: FlavorDisplayMode = .chart

    // savedFlavorMode → flavorMode 초기화는 onAppear에서 처리

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

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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

                    flavorModeChipset
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
        .onAppear {
            flavorMode = FlavorDisplayMode(rawValue: savedFlavorMode) ?? .chart
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

    // MARK: - Basic Info

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(WhiskeyCategory(rawValue: note.category)?.localizedName ?? note.category)
                if let age = note.age { Text("· \(age)\(String(localized: "년"))") }
                if let abv = note.abv { Text(String(format: "· %.1f%%", abv)) }
                if let price = note.price,
                   let formatted = priceFormatter.string(from: NSNumber(value: price)) {
                    let isKorean = Bundle.main.preferredLocalizations.first == "ko"
                    Text("· " + (isKorean ? "\(formatted)원" : "$\(formatted)"))
                }
            }
            .font(.subheadline)
            .foregroundStyle(AppColors.accent)
        }
    }

    // MARK: - Flavor Mode Chipset

    private var flavorModeChipset: some View {
        HStack(spacing: 8) {
            ForEach(FlavorDisplayMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { flavorMode = mode }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 12))
                        Text(mode.label)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        flavorMode == mode
                            ? AppColors.accent
                            : AppColors.tagBackground
                    )
                    .foregroundStyle(
                        flavorMode == mode
                            ? Color.white
                            : AppColors.accent
                    )
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Flavor Sections

    @ViewBuilder
    private var flavorSections: some View {
        let sections: [(title: String, type: FlavorType)] = [
            ("향 (Aroma)", .aroma), ("맛 (Taste)", .taste),
            ("질감 (Mouthfeel)", .mouthfeel), ("마무리 (Finish)", .finish)
        ]
        ForEach(sections, id: \.title) { section in
            let allItems = FlavorConstants.items(for: section.type)
            let intensityMap: [String: Int] = Dictionary(
                uniqueKeysWithValues: note.flavorIntensities
                    .filter { $0.flavorType == section.type.rawValue }
                    .map { ($0.name, $0.intensity) }
            )
            let hasAny = allItems.contains { (intensityMap[$0.name] ?? 0) > 0 }

            if hasAny {
                sectionHeader(LocalizedStringKey(section.title))

                switch flavorMode {
                case .chart:
                    let radarItems = allItems.map {
                        FlavorRadarChart.Item(
                            label: $0.name,
                            emoji: $0.emoji,
                            intensity: intensityMap[$0.name] ?? 0
                        )
                    }
                    FlavorRadarChart(items: radarItems)
                        .frame(height: 220)
                        .padding(.vertical, 8)

                case .list:
                    let sorted = allItems
                        .filter { (intensityMap[$0.name] ?? 0) > 0 }
                        .sorted { (intensityMap[$0.name] ?? 0) > (intensityMap[$1.name] ?? 0) }
                    ForEach(sorted, id: \.name) { item in
                        HStack {
                            Text("\(item.emoji) \(NSLocalizedString(item.name, comment: ""))")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            HStack(spacing: 3) {
                                ForEach(1...5, id: \.self) { i in
                                    Circle()
                                        .fill(i <= (intensityMap[item.name] ?? 0)
                                              ? AppColors.accent
                                              : AppColors.tagBackground)
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

    // MARK: - Helpers

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppColors.accent)
    }
}

// MARK: - FlavorDisplayMode

enum FlavorDisplayMode: String, CaseIterable {
    case chart, list

    var label: String {
        switch self {
        case .chart: String(localized: "차트")
        case .list:  String(localized: "목록")
        }
    }

    var description: String {
        switch self {
        case .chart: String(localized: "레이더 차트로 플레이버 분포를 한눈에 확인")
        case .list:  String(localized: "항목별 강도를 도트로 상세하게 확인")
        }
    }

    var icon: String {
        switch self {
        case .chart: "chart.xyaxis.line"
        case .list:  "list.bullet"
        }
    }
}
