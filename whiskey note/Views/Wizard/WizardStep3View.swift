import SwiftUI

struct WizardStep3View: View {
    @Binding var intensities: [String: Int]

    private let sections: [(title: String, items: [FlavorItem])] = [
        ("맛 (Taste)",        FlavorConstants.items(for: .taste)),
        ("질감 (Mouthfeel)",  FlavorConstants.items(for: .mouthfeel)),
        ("마무리 (Finish)",   FlavorConstants.items(for: .finish)),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(AppColors.accent)

                        ForEach(section.items, id: \.name) { item in
                            FlavorSliderRow(
                                item: item,
                                intensity: Binding(
                                    get: { intensities[item.name] ?? 0 },
                                    set: { intensities[item.name] = $0 }
                                )
                            )
                            Divider()
                        }
                    }
                }
            }
            .padding()
        }
    }
}
