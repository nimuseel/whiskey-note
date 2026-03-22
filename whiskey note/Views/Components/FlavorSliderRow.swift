import SwiftUI

struct FlavorSliderRow: View {
    let item: FlavorItem
    @Binding var intensity: Int   // 0~5

    var body: some View {
        HStack(spacing: 12) {
            Text(item.emoji)
                .font(.title3)
                .frame(width: 28)

            Text(item.name)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 60, alignment: .leading)

            Slider(
                value: Binding(
                    get: { Double(intensity) },
                    set: { intensity = Int($0.rounded()) }
                ),
                in: 0...5,
                step: 1
            )
            .tint(AppColors.accent)

            Text(intensity == 0 ? "–" : "\(intensity)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(intensity == 0 ? AppColors.textSecondary : AppColors.accent)
                .frame(width: 20, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @Previewable @State var intensity = 3
    FlavorSliderRow(
        item: FlavorItem(name: "피트", emoji: "🔥", type: .aroma),
        intensity: $intensity
    )
    .padding()
}
