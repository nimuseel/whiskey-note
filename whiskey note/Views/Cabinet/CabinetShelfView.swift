import SwiftUI

struct CabinetShelfView: View {
    let items: [(representative: WhiskeyNote, notes: [WhiskeyNote])]  // 최대 6개

    var body: some View {
        VStack(spacing: 0) {
            // Bottles row — align to bottom so varying heights sit on the shelf
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(items, id: \.representative.id) { item in
                    BottleView(note: item.representative)
                }
                Spacer()
            }
            .frame(height: 152)
            .padding(.horizontal, 8)

            // Shelf board
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#a07040"),
                            Color(hex: "#6b4820"),
                            Color(hex: "#3d2610")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 6)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 3)
        }
    }
}
