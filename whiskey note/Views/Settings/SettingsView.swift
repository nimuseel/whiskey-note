import SwiftUI

struct SettingsView: View {
    @AppStorage("flavorDisplayMode") private var savedMode: String = FlavorDisplayMode.chart.rawValue
    @State private var selectedMode: FlavorDisplayMode = .chart

    private let previewItems: [FlavorRadarChart.Item] = [
        .init(label: "과일",   emoji: "🍋", intensity: 4),
        .init(label: "꽃",    emoji: "🌸", intensity: 3),
        .init(label: "우디",   emoji: "🌳", intensity: 5),
        .init(label: "스파이시", emoji: "🌶️", intensity: 2),
        .init(label: "피트",   emoji: "💨", intensity: 4),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FlavorDisplayMode.allCases, id: \.self) { mode in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(mode.label)
                                            .foregroundStyle(AppColors.textPrimary)
                                        Text(mode.description)
                                            .font(.caption)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                } icon: {
                                    Image(systemName: mode.icon)
                                        .foregroundStyle(AppColors.accent)
                                }
                                Spacer()
                                if selectedMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColors.accent)
                                        .fontWeight(.semibold)
                                }
                            }
                            if selectedMode == mode {
                                previewFor(mode)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: selectedMode)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMode = mode
                            savedMode = mode.rawValue
                        }
                    }
                } header: {
                    Text("플레이버 기본 표시 방식")
                }
            }
            .navigationTitle("설정")
            .background(AppColors.background.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .onAppear {
                selectedMode = FlavorDisplayMode(rawValue: savedMode) ?? .chart
            }
        }
    }

    @ViewBuilder
    private func previewFor(_ mode: FlavorDisplayMode) -> some View {
        switch mode {
        case .chart:
            FlavorRadarChart(items: previewItems)
                .frame(height: 180)
                .padding(.vertical, 4)

        case .list:
            VStack(spacing: 8) {
                ForEach(previewItems.sorted { $0.intensity > $1.intensity }, id: \.label) { item in
                    HStack {
                        Text("\(item.emoji) \(NSLocalizedString(item.label, comment: ""))")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(1...5, id: \.self) { i in
                                Circle()
                                    .fill(i <= item.intensity
                                          ? AppColors.accent
                                          : AppColors.tagBackground)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
