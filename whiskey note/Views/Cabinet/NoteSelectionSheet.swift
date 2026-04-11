import SwiftUI

/// 같은 이름의 위스키에 노트가 여러 개 있을 때 표시되는 선택 시트.
/// 자체 NavigationStack을 포함해 sheet 안에서 NoteDetailView로 이동한다.
struct NoteSelectionSheet: View {
    let whiskey: WhiskeyNote      // representative — 이름 표시용
    let notes: [WhiskeyNote]      // newest-first 정렬된 전체 노트

    var body: some View {
        NavigationStack {
            List(notes) { note in
                NavigationLink(value: note) {
                    NoteRow(note: note)
                }
                .listRowBackground(Color(hex: "#2a1a08"))
                .listRowSeparatorTint(Color(red: 0.88, green: 0.78, blue: 0.60).opacity(0.15))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#1a1005"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(whiskey.name)
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        Text(String(localized: "\(notes.count)개의 노트 · 선택하세요"))
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.88, green: 0.78, blue: 0.60))
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: WhiskeyNote.self) { note in
                NoteDetailView(note: note)
            }
        }
    }
}

// MARK: - NoteRow

private struct NoteRow: View {
    let note: WhiskeyNote

    private static let warmCream = Color(red: 0.88, green: 0.78, blue: 0.60)

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: note.createdAt)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(Self.warmCream)
                if note.rating > 0 {
                    StarRatingView(
                        rating: .constant(note.rating),
                        isEditable: false,
                        starSize: 14
                    )
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(minHeight: 44)
    }
}
