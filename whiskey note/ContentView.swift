import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("홈", systemImage: "house.fill") }

            NoteListView()
                .tabItem { Label("노트", systemImage: "note.text") }

            StatsView()
                .tabItem { Label("통계", systemImage: "chart.bar.fill") }

            CabinetView()
                .tabItem { Label(String(localized: "술장"), systemImage: "wineglass") }

            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape.fill") }
        }
        .tint(AppColors.accent)
    }
}
