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
            }
            .listStyle(.plain)
            .navigationTitle(whiskey.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: WhiskeyNote.self) { note in
                NoteDetailView(note: note)
            }
        }
    }
}

// MARK: - NoteRow

private struct NoteRow: View {
    let note: WhiskeyNote

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: note.createdAt)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
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
        .padding(.vertical, 6)
    }
}
