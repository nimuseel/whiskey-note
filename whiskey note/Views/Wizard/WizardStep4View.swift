import SwiftUI

struct WizardStep4View: View {
    @Binding var rating: Double
    @Binding var memo: String
    @Binding var dish: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 별점
                VStack(alignment: .leading, spacing: 8) {
                    Text("전체 평점")
                        .font(.headline)
                        .foregroundStyle(AppColors.accent)
                    HStack {
                        StarRatingView(rating: $rating)
                        Spacer()
                        Text(rating == 0 ? "평가 없음" : String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Divider()

                // 메모
                VStack(alignment: .leading, spacing: 8) {
                    Text("메모")
                        .font(.headline)
                        .foregroundStyle(AppColors.accent)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $memo)
                            .accessibilityIdentifier("memoEditor")
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.tagBackground, lineWidth: 1)
                            )
                        if memo.isEmpty {
                            Text("자유롭게 기록해보세요")
                                .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                }

                // 안주
                VStack(alignment: .leading, spacing: 8) {
                    Text("같이 먹은 안주")
                        .font(.headline)
                        .foregroundStyle(AppColors.accent)
                    TextField("같이 먹은 안주", text: $dish)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.tagBackground, lineWidth: 1)
                        )
                }
            }
            .padding()
        }
    }
}
