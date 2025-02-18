import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasteNotes: [TasteNote]
    @State private var isCreateViewPresent = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(tasteNotes.sorted(by: { $0.createdAt < $1.createdAt })) { tasteNote in
                    NavigationLink {
                        UpdateView(tasteNote: .constant(tasteNote))
                    } label: {
                        VStack(alignment: .leading) {
                            Text("\(tasteNote.whiskey.name)")
                            HStack {
                                Text("\(tasteNote.whiskey.category) / \(tasteNote.dish)").font(.footnote)
                           }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button("추가하기") {
                        isCreateViewPresent = true
                    }
                }
            }
            .navigationDestination(isPresented: $isCreateViewPresent, destination: {
                CreateView()
            })
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasteNotes[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TasteNote.self, inMemory: true)
}
