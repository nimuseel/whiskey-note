import SwiftUI

struct MigrationLoadingView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🥃")
                    .font(.system(size: 64))

                ProgressView()
                    .tint(AppColors.accent)
                    .scaleEffect(1.2)

                Text("데이터를 불러오고 있습니다")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
