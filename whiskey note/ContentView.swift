import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasteNotes: [TasteNote]
    @State private var isCreateViewPresent = false
    
    @State private var showMainView: Bool = false

    var body: some View {
        ZStack {
            if showMainView {
                NavigationStack {
                    List {
                        ForEach(tasteNotes.sorted(by: { $0.createdAt < $1.createdAt })) { tasteNote in
                            NavigationLink {
                                UpdateView(tasteNote: .constant(tasteNote))
                            } label: {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 4) {
                                        Text(tasteNote.whiskey.name).font(.subheadline)
                                        Text("/ \(tasteNote.whiskey.category)").font(.subheadline)
                                    }
                                    Text(tasteNote.dish).font(.footnote).foregroundColor(.secondary)
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
            } else {
                LaunchView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showMainView = true
                            }
                        }
                    }
            }
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
