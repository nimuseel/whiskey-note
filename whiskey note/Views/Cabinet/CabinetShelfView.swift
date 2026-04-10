import SwiftUI

struct CabinetShelfView: View {
    let notes: [WhiskeyNote]  // 최대 6개

    var body: some View {
        VStack(spacing: 0) {
            // Bottles row — align to bottom so varying heights sit on the shelf
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(notes) { note in
                    NavigationLink(value: note) {
                        BottleView(note: note)
                    }
                    .buttonStyle(.plain)
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
