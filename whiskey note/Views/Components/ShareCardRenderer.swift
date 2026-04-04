import SwiftUI

enum ShareCardRenderer {

    /// WhiskeyNote를 1080×1080px PNG UIImage로 렌더링한다.
    /// - Parameters:
    ///   - note: 공유할 노트
    ///   - allNotes: 테이스팅 순번 계산용 전체 노트 배열
    /// - Returns: 렌더링된 UIImage. 실패 시 nil.
    @MainActor
    static func render(note: WhiskeyNote, allNotes: [WhiskeyNote]) -> UIImage? {
        let number = ShareCardHelper.tastingNumber(for: note, in: allNotes)
        let cardView = ShareCardView(note: note, tastingNumber: number)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0  // 360pt × 3 = 1080px
        return renderer.uiImage
    }
}
