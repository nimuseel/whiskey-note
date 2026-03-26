import SwiftUI

struct WizardStep2View: View {
    @Binding var intensities: [String: Int]

    private let aromaItems = FlavorConstants.items(for: .aroma)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("향을 얼마나 강하게 느꼈나요?")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.bottom, 8)

                ForEach(aromaItems, id: \.name) { item in
                    FlavorSliderRow(
                        item: item,
                        intensity: Binding(
                            get: { intensities["\(item.type.rawValue)_\(item.name)"] ?? 0 },
                            set: { intensities["\(item.type.rawValue)_\(item.name)"] = $0 }
                        )
                    )
                    Divider()
                }
            }
            .padding()
        }
    }
}
