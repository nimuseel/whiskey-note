import SwiftUI

struct CreateView: View {
    @State private var whiskeyName: String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField(text: $whiskeyName) {
                    Text("name")
                }
                .background(.white)
            }
            .background(.white)
        }
        .padding(.horizontal)
        
    }
}

#Preview {
    CreateView()
}
