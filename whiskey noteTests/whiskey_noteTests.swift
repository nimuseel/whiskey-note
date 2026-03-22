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
