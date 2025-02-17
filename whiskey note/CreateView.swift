import SwiftUI

class DirtyCheckViewModel: ObservableObject {
    @Published var isDirty = false
}

struct CreateView: View {
    @ObservedObject private var viewModel = DirtyCheckViewModel()
    
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
    
    @State private var aromas: [Aroma:Bool] = [
        .Fruity: false,
        .Floral: false,
        .Grainy: false,
        .Nutty: false,
        .Spicy: false,
        .Woody: false,
        .Peaty: false,
        .Winey: false,
        .Feinty: false,
    ] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var tastes: [Taste:Bool] = [
        .Sweet: false,
        .Salty: false,
        .Sour: false,
        .Bitter: false,
        .Umami: false,
    ] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var mouthfeels: [Mouthfeel:Bool] = [
        .Light: false,
        .Medium: false,
        .Full: false,
        .Smooth: false,
        .Rough: false,
        .Oily: false,
        .Dry: false,
    ] {
        didSet {
            checkDirty()
        }
    }
    
    @State private var finishes: [Finish:Bool] = [
        .Short: false,
        .Medium: false,
        .Long: false,
        .Warm: false,
        .Spicy: false,
        .Dry: false,
    ] {
        didSet {
            checkDirty()
        }
    }
    
   @State private var initialWhiskeyName: String = ""
   @State private var initialWhiskeyCategory: String = ""
   @State private var initialFoodName: String = ""
   @State private var initialAromas: [Aroma: Bool] = [:]
   @State private var initialTastes: [Taste: Bool] = [:]
   @State private var initialMouthfeels: [Mouthfeel: Bool] = [:]
   @State private var initialFinishes: [Finish: Bool] = [:]
    
    private func checkDirty() {
        viewModel.isDirty =
            whiskeyName != initialWhiskeyName &&
            whiskeyCategory != initialWhiskeyCategory &&
            foodName != initialFoodName &&
            aromas != initialAromas &&
            tastes != initialTastes &&
            mouthfeels != initialMouthfeels ||
            finishes != initialFinishes
        
        print(whiskeyName != initialWhiskeyName &&
              whiskeyCategory != initialWhiskeyCategory &&
              foodName != initialFoodName &&
              aromas != initialAromas &&
              tastes != initialTastes &&
              mouthfeels != initialMouthfeels ||
              finishes != initialFinishes)
    }
    
    var body: some View {
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
                                get: { aromas[aroma] ?? false },
                                set: { aromas[aroma] = $0 }
                            ))
                            .toggleStyle(.switch)
                        }
                    }
                }
                GroupBox(label: Text("맛")) {
                    ForEach(Taste.allCases) { taste in
                        HStack {
                            Toggle(taste.rawValue, isOn: Binding(
                                get: { tastes[taste] ?? false },
                                set: { tastes[taste] = $0 }
                            ))
                            .toggleStyle(.switch)
                        }
                    }
                }
                GroupBox(label: Text("질감")) {
                    ForEach(Mouthfeel.allCases) { mouthfeel in
                        HStack {
                            Toggle(mouthfeel.rawValue, isOn: Binding(
                                get: { mouthfeels[mouthfeel] ?? false },
                                set: { mouthfeels[mouthfeel] = $0 }
                            ))
                            .toggleStyle(.switch)
                        }
                    }
                }
                GroupBox(label: Text("마무리")) {
                    ForEach(Finish.allCases) { finish in
                        HStack {
                            Toggle(finish.rawValue, isOn: Binding(
                                get: { finishes[finish] ?? false },
                                set: { finishes[finish] = $0 }
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
        .toolbar {
            ToolbarItem {
                Button("추가") {
                    if viewModel.isDirty {
                        print("dirty")
                    } else {
                        print("clean")
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

#Preview {
    CreateView()
}
