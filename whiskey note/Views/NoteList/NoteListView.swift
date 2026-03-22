import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WhiskeyNote.createdAt, order: .reverse) private var notes: [WhiskeyNote]

    @State private var searchText = ""
    @State private var showWizard = false

    private var filteredNotes: [WhiskeyNote] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView("아직 기록이 없어요.", systemImage: "wineglass")
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            NavigationLink(value: note) {
                                NoteCardView(note: note)
                            }
                            .listRowBackground(AppColors.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                    .background(AppColors.background)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .searchable(text: $searchText, prompt: "위스키 이름 검색")
            .navigationTitle("테이스팅 노트")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showWizard = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: WhiskeyNote.self) { note in
                NoteDetailView(note: note)
            }
            .fullScreenCover(isPresented: $showWizard) {
                NoteWizardView()
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredNotes[index])
        }
    }
}
