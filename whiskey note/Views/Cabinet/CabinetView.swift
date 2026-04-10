import SwiftUI
import SwiftData


struct CabinetView: View {
    @Query(sort: \WhiskeyNote.createdAt) private var notes: [WhiskeyNote]

    private var shelves: [[WhiskeyNote]] {
        stride(from: 0, to: notes.count, by: 6).map {
            Array(notes[$0..<min($0 + 6, notes.count)])
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(hex: "#1a1005"),
                        Color(hex: "#2a1608"),
                        Color(hex: "#1a0e05")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Ceiling light
                RadialGradient(
                    colors: [Color(red: 1, green: 0.86, blue: 0.39).opacity(0.15), .clear],
                    center: .top,
                    startRadius: 0,
                    endRadius: 280
                )
                .ignoresSafeArea()
                .frame(maxHeight: 300)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Custom white large title
                        Text(String(localized: "술장"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        if notes.isEmpty {
                            emptyState
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(shelves.enumerated()), id: \.offset) { _, shelf in
                                    CabinetShelfView(notes: shelf)
                                }
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: WhiskeyNote.self) { note in
                NoteDetailView(note: note)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wineglass")
                .font(.system(size: 48))
                .foregroundStyle(Color.white.opacity(0.2))
            Text(String(localized: "첫 위스키를 기록해보세요"))
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.35))
        }
    }
}
