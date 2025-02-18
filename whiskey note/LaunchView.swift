import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack {
            Image("WhiskeyNote")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
        }
    }
}

#Preview {
    LaunchView()
}
