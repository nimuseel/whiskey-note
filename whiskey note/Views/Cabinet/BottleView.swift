import SwiftUI

// MARK: - Design System

enum BottleDesign {

    // MARK: Layout constants
    enum Layout {
        // Body heights by age tier
        static let heightNAS: CGFloat      = 84    // no age statement
        static let heightYoung: CGFloat    = 96    // 1–12y
        static let heightMature: CGFloat   = 108   // 13–18y
        static let heightOld: CGFloat      = 120   // 19y+

        // Body widths by category
        static let widthWide: CGFloat      = 30    // bourbon
        static let widthStandard: CGFloat  = 27    // single malt
        static let widthNarrow: CGFloat    = 25    // blended / irish / other
        static let widthSlim: CGFloat      = 22    // japanese

        // Proportional ratios (relative to bodyWidth / bodyHeight)
        static let capWidthRatio: CGFloat      = 0.48
        static let capHeight: CGFloat          = 7
        static let neckWidthRatio: CGFloat     = 0.45
        static let neckHeightRatio: CGFloat    = 0.18
        static let bodyCornerRadius: CGFloat   = 4
        static let capCornerRadius: CGFloat    = 2
        static let highlightStripeWidth: CGFloat = 2

        // Label stripe
        static let labelWidthRatio: CGFloat    = 0.8
        static let labelHeightRatio: CGFloat   = 0.28
        static let labelOffsetXRatio: CGFloat  = 0.1
        static let labelOffsetYRatio: CGFloat  = 0.30

        // Name label
        static let nameFontSize: CGFloat   = 9
        static let nameLabelWidth: CGFloat = 48
        static let nameLabelTopPadding: CGFloat = 4
    }

    // MARK: Glow thresholds
    enum GlowThreshold {
        static let strong: Double  = 4.5
        static let subtle: Double  = 4.0
    }

    enum GlowOpacity {
        static let strong: Double  = 0.45
        static let subtle: Double  = 0.25
        static let none: Double    = 0.0
    }

    enum GlowRadius {
        static let strong: CGFloat = 12
        static let subtle: CGFloat = 6
    }

    // MARK: Surface opacities
    enum Surface {
        static let highlight: Double    = 0.08
        static let labelFill: Double    = 0.07
        static let labelStroke: Double  = 0.10
    }

    // MARK: Name label color (warm cream, readable on dark wood)
    static let nameColor: Color = Color(red: 0.88, green: 0.78, blue: 0.60)

    // MARK: Colors
    struct Colors {
        let gradientTop: Color
        let gradientBottom: Color
        let cap: Color
    }

    static func colors(for category: WhiskeyCategory?) -> Colors {
        switch category {
        case .singleMalt:
            return Colors(gradientTop: Color(hex: "#c8820a"), gradientBottom: Color(hex: "#7a4c08"), cap: Color(hex: "#c0a050"))
        case .blended:
            return Colors(gradientTop: Color(hex: "#d4a830"), gradientBottom: Color(hex: "#8a6c18"), cap: Color(hex: "#b09040"))
        case .bourbon:
            return Colors(gradientTop: Color(hex: "#b06014"), gradientBottom: Color(hex: "#6a3408"), cap: Color(hex: "#c08040"))
        case .irish:
            return Colors(gradientTop: Color(hex: "#5a8a30"), gradientBottom: Color(hex: "#2a4e14"), cap: Color(hex: "#60a050"))
        case .japanese:
            return Colors(gradientTop: Color(hex: "#6040a0"), gradientBottom: Color(hex: "#2a1860"), cap: Color(hex: "#a090d0"))
        case .other, nil:
            return Colors(gradientTop: Color(hex: "#4a5a6a"), gradientBottom: Color(hex: "#2a3440"), cap: Color(hex: "#607080"))
        }
    }

    static func bodyHeight(age: Int?) -> CGFloat {
        guard let age = age else { return Layout.heightNAS }
        switch age {
        case 1...12:  return Layout.heightYoung
        case 13...18: return Layout.heightMature
        default:      return Layout.heightOld
        }
    }

    static func bodyWidth(for category: WhiskeyCategory?) -> CGFloat {
        switch category {
        case .bourbon:                        return Layout.widthWide
        case .singleMalt:                     return Layout.widthStandard
        case .blended, .irish, .other, nil:   return Layout.widthNarrow
        case .japanese:                       return Layout.widthSlim
        }
    }

    static func glowOpacity(rating: Double) -> Double {
        switch rating {
        case GlowThreshold.strong...: return GlowOpacity.strong
        case GlowThreshold.subtle...: return GlowOpacity.subtle
        default:                      return GlowOpacity.none
        }
    }
}

// MARK: - BottleView

struct BottleView: View {
    let note: WhiskeyNote          // representative — 외관 결정
    let allNotes: [WhiskeyNote]    // 전체 노트 (탭 동작 결정)

    @State private var showSheet = false

    private var category: WhiskeyCategory? {
        WhiskeyCategory(rawValue: note.category)
    }
    private var colors: BottleDesign.Colors { BottleDesign.colors(for: category) }
    private var bodyH: CGFloat { BottleDesign.bodyHeight(age: note.age) }
    private var bodyW: CGFloat { BottleDesign.bodyWidth(for: category) }
    private var glowOp: Double { BottleDesign.glowOpacity(rating: note.rating) }
    private var glowRadius: CGFloat {
        glowOp >= BottleDesign.GlowOpacity.strong
            ? BottleDesign.GlowRadius.strong
            : BottleDesign.GlowRadius.subtle
    }
    private var displayName: String { note.name.isEmpty ? "Unnamed" : note.name }

    private var accessibilityDescription: String {
        var parts = [displayName]
        if let cat = category { parts.append(cat.localizedName) }
        if let age = note.age { parts.append("\(age)년산") }
        if note.rating > 0 { parts.append("별점 \(Int(note.rating))점") }
        if allNotes.count > 1 { parts.append("\(allNotes.count)개의 노트") }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        Group {
            if allNotes.count == 1 {
                NavigationLink(value: allNotes[0]) {
                    bottleGraphic
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    showSheet = true
                } label: {
                    bottleGraphic
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showSheet) {
                    NoteSelectionSheet(whiskey: note, notes: allNotes)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(allNotes.count == 1
            ? String(localized: "탭하면 노트 상세로 이동합니다")
            : String(localized: "탭하면 노트 목록이 열립니다"))
    }

    private var bottleGraphic: some View {
        VStack(spacing: 0) {
            // Cap
            RoundedRectangle(cornerRadius: BottleDesign.Layout.capCornerRadius)
                .fill(colors.cap)
                .frame(width: bodyW * BottleDesign.Layout.capWidthRatio,
                       height: BottleDesign.Layout.capHeight)

            // Neck
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [colors.gradientTop, colors.gradientBottom],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: bodyW * BottleDesign.Layout.neckWidthRatio,
                       height: bodyH * BottleDesign.Layout.neckHeightRatio)

            // Body
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: BottleDesign.Layout.bodyCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [colors.gradientTop, colors.gradientBottom],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: bodyW, height: bodyH)
                    .shadow(
                        color: colors.gradientTop.opacity(glowOp),
                        radius: glowRadius, x: 0, y: 0
                    )
                    .overlay(
                        // Highlight stripe (left edge)
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(BottleDesign.Surface.highlight))
                                .frame(width: BottleDesign.Layout.highlightStripeWidth)
                            Spacer()
                        }
                        .frame(width: bodyW, height: bodyH)
                        .clipShape(RoundedRectangle(cornerRadius: BottleDesign.Layout.bodyCornerRadius))
                    )

                // Label stripe
                RoundedRectangle(cornerRadius: BottleDesign.Layout.capCornerRadius)
                    .fill(Color.white.opacity(BottleDesign.Surface.labelFill))
                    .overlay(
                        RoundedRectangle(cornerRadius: BottleDesign.Layout.capCornerRadius)
                            .stroke(Color.white.opacity(BottleDesign.Surface.labelStroke), lineWidth: 0.5)
                    )
                    .frame(width: bodyW * BottleDesign.Layout.labelWidthRatio,
                           height: bodyH * BottleDesign.Layout.labelHeightRatio)
                    .offset(x: bodyW * BottleDesign.Layout.labelOffsetXRatio,
                            y: bodyH * BottleDesign.Layout.labelOffsetYRatio)
            }

            // Name label
            Text(displayName)
                .font(.system(size: BottleDesign.Layout.nameFontSize, weight: .medium))
                .foregroundStyle(BottleDesign.nameColor)
                .frame(width: BottleDesign.Layout.nameLabelWidth)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.top, BottleDesign.Layout.nameLabelTopPadding)
        }
    }
}
