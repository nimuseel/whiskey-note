import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Double
    var isEditable: Bool = true
    var starSize: CGFloat = 28

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                starImage(for: index)
                    .font(.system(size: starSize))
                    .foregroundStyle(AppColors.star)
                    .overlay(
                        GeometryReader { _ in
                            if isEditable {
                                HStack(spacing: 0) {
                                    // 왼쪽 반: 0.5 단위
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            rating = Double(index) + 0.5
                                        }
                                    // 오른쪽 반: 1.0 단위
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            rating = Double(index) + 1.0
                                        }
                                }
                            }
                        }
                    )
            }
        }
    }

    private func starImage(for index: Int) -> Image {
        let fullThreshold = Double(index) + 1.0
        let halfThreshold = Double(index) + 0.5
        if rating >= fullThreshold {
            return Image(systemName: "star.fill")
        } else if rating >= halfThreshold {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}

#Preview {
    @Previewable @State var rating = 3.5
    StarRatingView(rating: $rating)
        .padding()
}
