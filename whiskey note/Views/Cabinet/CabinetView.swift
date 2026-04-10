import SwiftUI
import SwiftData

// Targets only this NavigationStack's navigationBar — no global side effects
private struct WhiteTitleConfigurator: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }
    func updateUIViewController(_ vc: UIViewController, context: Context) {
        guard let nc = vc.navigationController else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        nc.navigationBar.standardAppearance = appearance
        nc.navigationBar.scrollEdgeAppearance = appearance
    }
}

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

                if notes.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(shelves.enumerated()), id: \.offset) { _, shelf in
                                CabinetShelfView(notes: shelf)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(String(localized: "술장"))
            .navigationBarTitleDisplayMode(.large)
            .background(WhiteTitleConfigurator())
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
