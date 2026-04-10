import Foundation

// MARK: - Autocomplete Helper

/// 입력 문자열과 대소문자 무시 부분 일치하는 이름 목록을 반환한다.
/// - Parameters:
///   - input: 사용자가 입력한 문자열 (빈 문자열이면 빈 배열 반환)
///   - names: 비교 대상 이름 목록 (중복 제거·정렬 완료 상태를 가정)
func filterSuggestions(_ input: String, from names: [String]) -> [String] {
    guard !input.isEmpty else { return [] }
    return names.filter { $0.localizedCaseInsensitiveContains(input) }
}
