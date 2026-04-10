import Testing
import Foundation
@testable import whiskey_note

// MARK: - FlavorConstants Tests

@Suite("FlavorConstants")
struct FlavorConstantsTests {

    @Test func totalCount() {
        #expect(FlavorConstants.all.count == 27)
    }

    @Test func aromaCount() {
        let aromas = FlavorConstants.all.filter { $0.type == .aroma }
        #expect(aromas.count == 9)
    }

    @Test func tasteCount() {
        let tastes = FlavorConstants.all.filter { $0.type == .taste }
        #expect(tastes.count == 5)
    }

    @Test func mouthfeelCount() {
        let mouthfeels = FlavorConstants.all.filter { $0.type == .mouthfeel }
        #expect(mouthfeels.count == 7)
    }

    @Test func finishCount() {
        let finishes = FlavorConstants.all.filter { $0.type == .finish }
        #expect(finishes.count == 6)
    }

    @Test func noDuplicateNamesWithinType() {
        for type in FlavorType.allCases {
            let names = FlavorConstants.items(for: type).map { $0.name }
            #expect(Set(names).count == names.count, "Duplicate name in \(type.rawValue)")
        }
    }

    @Test func noEmptyEmoji() {
        for item in FlavorConstants.all {
            #expect(!item.emoji.isEmpty, "\(item.name) has empty emoji")
        }
    }
}

// MARK: - StarRating Logic Tests

@Suite("StarRating Logic")
struct StarRatingTests {

    func ratingForTap(starIndex: Int, isLeftHalf: Bool) -> Double {
        let base = Double(starIndex + 1)
        return isLeftHalf ? base - 0.5 : base
    }

    @Test func leftHalfOfFirstStar() {
        #expect(ratingForTap(starIndex: 0, isLeftHalf: true) == 0.5)
    }

    @Test func rightHalfOfFirstStar() {
        #expect(ratingForTap(starIndex: 0, isLeftHalf: false) == 1.0)
    }

    @Test func leftHalfOfFifthStar() {
        #expect(ratingForTap(starIndex: 4, isLeftHalf: true) == 4.5)
    }

    @Test func rightHalfOfFifthStar() {
        #expect(ratingForTap(starIndex: 4, isLeftHalf: false) == 5.0)
    }
}

// MARK: - WizardDirtyCheck Tests

@Suite("WizardDirtyCheck")
struct WizardDirtyCheckTests {

    func isDirtyCreate(
        name: String = "",
        photoData: Data? = nil,
        abv: String = "",
        age: String = "",
        price: String = "",
        intensities: [String: Int] = [:],
        memo: String = "",
        dish: String = ""
    ) -> Bool {
        !name.isEmpty
        || photoData != nil
        || !abv.isEmpty || !age.isEmpty || !price.isEmpty
        || intensities.values.contains { $0 > 0 }
        || !memo.isEmpty || !dish.isEmpty
    }

    @Test func emptyStateIsNotDirty() {
        #expect(!isDirtyCreate())
    }

    @Test func nameInputIsDirty() {
        #expect(isDirtyCreate(name: "Laphroaig"))
    }

    @Test func intensityZeroIsNotDirty() {
        #expect(!isDirtyCreate(intensities: ["피트": 0]))
    }

    @Test func intensityAboveZeroIsDirty() {
        #expect(isDirtyCreate(intensities: ["피트": 3]))
    }

    @Test func memoInputIsDirty() {
        #expect(isDirtyCreate(memo: "훈연향"))
    }
}

// MARK: - Stats Calculations Tests

@Suite("StatsCalculations")
struct StatsCalculationsTests {

    func topAromaAverages(from data: [(name: String, intensity: Int)]) -> [(name: String, avg: Double)] {
        var sums: [String: Int] = [:]
        var counts: [String: Int] = [:]
        for (name, intensity) in data where intensity > 0 {
            sums[name, default: 0] += intensity
            counts[name, default: 0] += 1
        }
        return sums.map { name, sum in
            (name: name, avg: Double(sum) / Double(counts[name]!))
        }
        .sorted { $0.avg > $1.avg }
    }

    @Test func averageExcludesZero() {
        let data: [(String, Int)] = [("피트", 5), ("피트", 0), ("과일", 3)]
        let result = topAromaAverages(from: data)
        let peat = result.first { $0.name == "피트" }!
        #expect(peat.avg == 5.0)
    }

    @Test func averageWithMultipleNotes() {
        let data: [(String, Int)] = [("피트", 4), ("피트", 2)]
        let result = topAromaAverages(from: data)
        let peat = result.first { $0.name == "피트" }!
        #expect(peat.avg == 3.0)
    }

    @Test func topIsSortedDescending() {
        let data: [(String, Int)] = [("피트", 2), ("과일", 5)]
        let result = topAromaAverages(from: data)
        #expect(result[0].name == "과일")
    }

    @Test func allZeroReturnsEmpty() {
        let data: [(String, Int)] = [("피트", 0), ("과일", 0)]
        let result = topAromaAverages(from: data)
        #expect(result.isEmpty)
    }
}

// MARK: - ShareCardHelper Tests

@Suite("ShareCardHelper")
struct ShareCardHelperTests {

    // MARK: tastingNumber

    @Test func tastingNumberIsOneBased() {
        let note = makeNote(createdAt: Date(timeIntervalSince1970: 100))
        #expect(ShareCardHelper.tastingNumber(for: note, in: [note]) == 1)
    }

    @Test func tastingNumberFallsBackToOneWhenNotInList() {
        let note = makeNote(createdAt: Date(timeIntervalSince1970: 100))
        let other = makeNote(createdAt: Date(timeIntervalSince1970: 200))
        #expect(ShareCardHelper.tastingNumber(for: note, in: [other]) == 1)
    }

    @Test func tastingNumberReflectsOrder() {
        let note1 = makeNote(createdAt: Date(timeIntervalSince1970: 100))
        let note2 = makeNote(createdAt: Date(timeIntervalSince1970: 200))
        #expect(ShareCardHelper.tastingNumber(for: note2, in: [note2, note1]) == 2)
    }

    @Test func tastingNumberTiebreakById() {
        let date = Date(timeIntervalSince1970: 100)
        let noteA = makeNote(createdAt: date)
        let noteB = makeNote(createdAt: date)
        let all = [noteA, noteB].sorted { $0.id.uuidString < $1.id.uuidString }
        #expect(ShareCardHelper.tastingNumber(for: all[0], in: [noteA, noteB]) == 1)
        #expect(ShareCardHelper.tastingNumber(for: all[1], in: [noteA, noteB]) == 2)
    }

    // MARK: topAromaItems

    @Test func topAromaItemsReturnsUpToLimit() {
        let note = makeNote(aromaIntensities: ["과일": 5, "꽃": 4, "곡물": 3, "견과류": 2])
        let result = ShareCardHelper.topAromaItems(from: note, limit: 3)
        #expect(result.count == 3)
    }

    @Test func topAromaItemsAreSortedByIntensityDescending() {
        let note = makeNote(aromaIntensities: ["과일": 3, "꽃": 5, "곡물": 1])
        let result = ShareCardHelper.topAromaItems(from: note, limit: 3)
        #expect(result[0].item.name == "꽃")
        #expect(result[1].item.name == "과일")
        #expect(result[2].item.name == "곡물")
    }

    @Test func topAromaItemsTiebreakFollowsFlavorConstantsOrder() {
        let note = makeNote(aromaIntensities: ["꽃": 3, "과일": 3])
        let result = ShareCardHelper.topAromaItems(from: note, limit: 2)
        #expect(result[0].item.name == "과일")
        #expect(result[1].item.name == "꽃")
    }

    @Test func topAromaItemsExcludesZeroIntensity() {
        let note = makeNote(aromaIntensities: ["과일": 0, "꽃": 3])
        let result = ShareCardHelper.topAromaItems(from: note, limit: 3)
        #expect(result.count == 1)
        #expect(result[0].item.name == "꽃")
    }

    // MARK: radarAxisValues

    @Test func radarAxisValuesHasFourElements() {
        let note = makeNote()
        #expect(ShareCardHelper.radarAxisValues(from: note).count == 4)
    }

    @Test func radarAxisValuesAveragesIntensities() {
        let note = makeNote(aromaIntensities: ["과일": 2, "꽃": 4])
        let values = ShareCardHelper.radarAxisValues(from: note)
        #expect(abs(values[0] - 3.0) < 0.001)
    }

    @Test func radarAxisValuesExcludesZero() {
        let note = makeNote(aromaIntensities: ["과일": 4, "꽃": 0])
        let values = ShareCardHelper.radarAxisValues(from: note)
        #expect(abs(values[0] - 4.0) < 0.001)
    }

    @Test func radarAxisValuesZeroForEmptyType() {
        let note = makeNote()
        let values = ShareCardHelper.radarAxisValues(from: note)
        #expect(values.allSatisfy { $0 == 0.0 })
    }

    @Test func radarAxisValuesTasteAxisAveragesCorrectly() {
        let note = makeNote(intensities: [(.taste, "단맛", 3), (.taste, "짠맛", 5)])
        let values = ShareCardHelper.radarAxisValues(from: note)
        #expect(abs(values[1] - 4.0) < 0.001)
    }

    @Test func radarAxisValuesEachAxisIndependent() {
        let note = makeNote(intensities: [(.aroma, "과일", 4), (.taste, "단맛", 2)])
        let values = ShareCardHelper.radarAxisValues(from: note)
        #expect(abs(values[0] - 4.0) < 0.001)
        #expect(abs(values[1] - 2.0) < 0.001)
        #expect(values[2] == 0.0)
        #expect(values[3] == 0.0)
    }

    // MARK: hasAnyFlavor

    @Test func hasAnyFlavorFalseWhenAllZero() {
        let note = makeNote(aromaIntensities: ["과일": 0])
        #expect(!ShareCardHelper.hasAnyFlavor(from: note))
    }

    @Test func hasAnyFlavorTrueWhenAnyPositive() {
        let note = makeNote(aromaIntensities: ["과일": 3])
        #expect(ShareCardHelper.hasAnyFlavor(from: note))
    }

    // MARK: - Helpers

    private func makeNote(
        createdAt: Date = Date(),
        aromaIntensities: [String: Int] = [:],
        intensities: [(FlavorType, String, Int)] = []
    ) -> WhiskeyNote {
        let note = WhiskeyNote(name: "Test")
        note.createdAt = createdAt
        let aromaItems = aromaIntensities.map { name, intensity -> FlavorIntensity in
            let fi = FlavorIntensity(flavorType: .aroma, name: name, intensity: intensity)
            fi.note = note
            return fi
        }
        let otherItems = intensities.map { type, name, intensity -> FlavorIntensity in
            let fi = FlavorIntensity(flavorType: type, name: name, intensity: intensity)
            fi.note = note
            return fi
        }
        note.flavorIntensities = aromaItems + otherItems
        return note
    }
}

// MARK: - BottleDesign Tests

@Suite("BottleDesign")
struct BottleDesignTests {

    // bodyHeight — boundary tests for each age tier
    @Test func bodyHeightNilAge() {
        #expect(BottleDesign.bodyHeight(age: nil) == BottleDesign.Layout.heightNAS)
    }
    @Test func bodyHeightAge10() {
        #expect(BottleDesign.bodyHeight(age: 10) == BottleDesign.Layout.heightYoung)
    }
    @Test func bodyHeightAge12() {
        // upper boundary of young tier
        #expect(BottleDesign.bodyHeight(age: 12) == BottleDesign.Layout.heightYoung)
    }
    @Test func bodyHeightAge13() {
        // lower boundary of mature tier
        #expect(BottleDesign.bodyHeight(age: 13) == BottleDesign.Layout.heightMature)
    }
    @Test func bodyHeightAge18() {
        // upper boundary of mature tier
        #expect(BottleDesign.bodyHeight(age: 18) == BottleDesign.Layout.heightMature)
    }
    @Test func bodyHeightAge19() {
        // lower boundary of old tier
        #expect(BottleDesign.bodyHeight(age: 19) == BottleDesign.Layout.heightOld)
    }
    @Test func bodyHeightAge30() {
        #expect(BottleDesign.bodyHeight(age: 30) == BottleDesign.Layout.heightOld)
    }

    // bodyWidth — one test per distinct width value
    @Test func bodyWidthBourbon() {
        #expect(BottleDesign.bodyWidth(for: .bourbon) == BottleDesign.Layout.widthWide)
    }
    @Test func bodyWidthSingleMalt() {
        #expect(BottleDesign.bodyWidth(for: .singleMalt) == BottleDesign.Layout.widthStandard)
    }
    @Test func bodyWidthJapanese() {
        #expect(BottleDesign.bodyWidth(for: .japanese) == BottleDesign.Layout.widthSlim)
    }
    @Test func bodyWidthOther() {
        #expect(BottleDesign.bodyWidth(for: .other) == BottleDesign.Layout.widthNarrow)
    }

    // glowOpacity — boundary tests for each tier
    @Test func glowOpacityNoRating() {
        #expect(BottleDesign.glowOpacity(rating: 0) == BottleDesign.GlowOpacity.none)
    }
    @Test func glowOpacityBelow4() {
        #expect(BottleDesign.glowOpacity(rating: 3.5) == BottleDesign.GlowOpacity.none)
    }
    @Test func glowOpacityAt4() {
        // lower boundary of subtle tier
        #expect(BottleDesign.glowOpacity(rating: 4.0) == BottleDesign.GlowOpacity.subtle)
    }
    @Test func glowOpacityAt4_4() {
        // upper boundary of subtle tier
        #expect(BottleDesign.glowOpacity(rating: 4.4) == BottleDesign.GlowOpacity.subtle)
    }
    @Test func glowOpacityAt4_5() {
        // lower boundary of strong tier
        #expect(BottleDesign.glowOpacity(rating: 4.5) == BottleDesign.GlowOpacity.strong)
    }
    @Test func glowOpacityAt5() {
        #expect(BottleDesign.glowOpacity(rating: 5.0) == BottleDesign.GlowOpacity.strong)
    }
}
