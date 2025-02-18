import SwiftUI
import SwiftData

class DirtyCheckViewModel: ObservableObject {
    @Published var isDirty = false
}

struct CreateView: View {
    @ObservedObject private var viewModel = DirtyCheckViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var whiskeyName: String = "" {
        didSet {
            checkDirty()
        }
    }
    @State private var whiskeyCategory: String = "" {
        didSet {
            checkDirty()
        }
    }
    @State private var foodName: String = "" {
        didSet {
            checkDirty()
        }
    }
    
    @State private var aromas: [Aroma] = [] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var tastes: [Taste] = [] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var mouthfeels: [Mouthfeel] = [] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var finishes: [Finish] = [] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var initialWhiskeyName: String = ""
    @State private var initialWhiskeyCategory: String = ""
    @State private var initialFoodName: String = ""
    @State private var initialAromas: [Aroma] = []
    @State private var initialTastes: [Taste] = []
    @State private var initialMouthfeels: [Mouthfeel] = []
    @State private var initialFinishes: [Finish] = []
    
    private func checkDirty() {
        viewModel.isDirty =
            whiskeyName != initialWhiskeyName &&
            whiskeyCategory != initialWhiskeyCategory &&
            foodName != initialFoodName &&
            aromas != initialAromas &&
            tastes != initialTastes &&
            mouthfeels != initialMouthfeels ||
            finishes != initialFinishes
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    GroupBox(label: Text("위스키")) {
                        TextField(text: $whiskeyName) {
                            Text("위스키 이름 입력")
                        }
                    }
                    GroupBox(label: Text("위스키 종류")) {
                        TextField(text: $whiskeyCategory) {
                            Text("위스키 종류 입력")
                        }
                    }
                    GroupBox(label: Text("향")) {
                        ForEach(Aroma.allCases) { aroma in
                            HStack {
                                Toggle(aroma.rawValue, isOn: Binding(
                                    get: { aromas.contains(aroma) },
                                    set: { isOn in
                                        if isOn {
                                            aromas.append(aroma)
                                        } else {
                                            aromas.removeAll(where: { $0 == aroma })
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    GroupBox(label: Text("맛")) {
                        ForEach(Taste.allCases) { taste in
                            HStack {
                                Toggle(taste.rawValue, isOn: Binding(
                                    get: { tastes.contains(taste) },
                                    set: { isOn in
                                        if isOn {
                                            tastes.append(taste)
                                        } else {
                                            tastes.removeAll(where: { $0 == taste })
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    GroupBox(label: Text("질감")) {
                        ForEach(Mouthfeel.allCases) { mouthfeel in
                            HStack {
                                Toggle(mouthfeel.rawValue, isOn: Binding(
                                    get: { mouthfeels.contains(mouthfeel) },
                                    set: { isOn in
                                        if isOn {
                                            mouthfeels.append(mouthfeel)
                                        } else {
                                            mouthfeels.removeAll(where: { $0 == mouthfeel })
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    GroupBox(label: Text("마무리")) {
                        ForEach(Finish.allCases) { finish in
                            HStack {
                                Toggle(finish.rawValue, isOn: Binding(
                                    get: { finishes.contains(finish) },
                                    set: { isOn in
                                        if isOn {
                                            finishes.append(finish)
                                        } else {
                                            finishes.removeAll(where: { $0 == finish })
                                        }
                                    }
                                ))
                                .toggleStyle(.switch)
                            }
                        }
                    }
                    GroupBox(label: Text("같이 먹은 안주")) {
                        TextField(text: $foodName) {
                            Text("같이 먹은 안주 입력")
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("노트 추가하기")
            .toolbar {
                ToolbarItem {
                    Button("추가") {
                        if viewModel.isDirty {
                            let newWhiskey = Whiskey(name: whiskeyName, category: whiskeyCategory)
                            let newTasteNote = TasteNote(whiskey: newWhiskey, aroma: aromas, taste: tastes, mouthfeel: mouthfeels, finish: finishes, dish: foodName, createdAt: Date())
                            
                            newWhiskey.tasteNotes.append(newTasteNote)
                            newTasteNote.whiskey = newWhiskey
                            
                            modelContext.insert(newWhiskey)
                            modelContext.insert(newTasteNote)
                                                     
                            viewModel.isDirty = false
                            
                            dismiss()
                        } else {
                            
                        }
                    }
                    .disabled(!viewModel.isDirty)
                }
            }
            .onAppear {
              initialWhiskeyName = whiskeyName
              initialWhiskeyCategory = whiskeyCategory
              initialFoodName = foodName
              initialAromas = aromas
              initialTastes = tastes
              initialMouthfeels = mouthfeels
              initialFinishes = finishes
            }
        }
    }
}

#Preview {
    CreateView()
}
