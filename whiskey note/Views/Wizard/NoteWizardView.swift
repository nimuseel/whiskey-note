import SwiftUI
import PhotosUI
import SwiftData

struct NoteWizardView: View {
    var existingNote: WhiskeyNote?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 1
    @State private var showCancelAlert = false

    // Step 1
    @State private var name = ""
    @State private var category = WhiskeyCategory.singleMalt.rawValue
    @State private var abvText = ""
    @State private var ageText = ""
    @State private var priceText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    // Step 2 & 3
    @State private var intensities: [String: Int] = [:]

    // Step 4
    @State private var rating: Double = 0.0
    @State private var memo = ""
    @State private var dish = ""

    @State private var initialSnapshot: EditSnapshot?

    var isEditMode: Bool { existingNote != nil }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                stepContent
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("저장하지 않고 나가시겠어요?", isPresented: $showCancelAlert) {
                Button("나가기", role: .destructive) { dismiss() }
                Button("계속 작성", role: .cancel) {}
            }
            .onAppear { loadExistingNote() }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? AppColors.accent : AppColors.tagBackground)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            WizardStep1View(name: $name, category: $category,
                            abv: $abvText, age: $ageText, price: $priceText,
                            selectedPhoto: $selectedPhoto, photoData: $photoData)
        case 2:
            WizardStep2View(intensities: $intensities)
        case 3:
            WizardStep3View(intensities: $intensities)
        default:
            WizardStep4View(rating: $rating, memo: $memo, dish: $dish)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(currentStep == 1 ? "취소" : "이전") {
                if currentStep == 1 {
                    handleCancel()
                } else {
                    currentStep -= 1
                }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            if currentStep < 4 {
                Button("다음") { currentStep += 1 }
                    .accessibilityIdentifier("wizardNext")
                    .disabled(currentStep == 1 && name.trimmingCharacters(in: .whitespaces).isEmpty)
            } else {
                Button("저장") { saveNote() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.bold)
            }
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 1: "사진 & 기본 정보"
        case 2: "향 (Aroma)"
        case 3: "맛·질감·마무리"
        default: "총평"
        }
    }

    // MARK: - Cancel Logic

    private func handleCancel() {
        if isDirty { showCancelAlert = true } else { dismiss() }
    }

    private var isDirty: Bool {
        if isEditMode {
            guard let snap = initialSnapshot else { return false }
            return name != snap.name
                || category != snap.category
                || abvText != snap.abvText
                || ageText != snap.ageText
                || priceText != snap.priceText
                || photoData != snap.photoData
                || intensities != snap.intensities
                || rating != snap.rating
                || memo != snap.memo
                || dish != snap.dish
        } else {
            return !name.isEmpty
                || photoData != nil
                || !abvText.isEmpty || !ageText.isEmpty || !priceText.isEmpty
                || intensities.values.contains { $0 > 0 }
                || !memo.isEmpty || !dish.isEmpty
        }
    }

    // MARK: - Load Existing Note

    private func loadExistingNote() {
        guard let note = existingNote else { return }
        name = note.name
        category = note.category
        abvText = note.abv.map { String($0) } ?? ""
        ageText = note.age.map { String($0) } ?? ""
        priceText = note.price.map { String($0) } ?? ""
        photoData = note.photoData
        rating = note.rating
        memo = note.memo
        dish = note.dish

        var dict: [String: Int] = [:]
        for item in FlavorConstants.all { dict[item.name] = 0 }
        for fi in note.flavorIntensities { dict[fi.name] = fi.intensity }
        intensities = dict

        initialSnapshot = EditSnapshot(
            name: name, category: category,
            abvText: abvText, ageText: ageText, priceText: priceText,
            photoData: photoData, intensities: intensities,
            rating: rating, memo: memo, dish: dish
        )
    }

    // MARK: - Save

    private func saveNote() {
        let note = existingNote ?? WhiskeyNote()

        note.name = name.trimmingCharacters(in: .whitespaces)
        note.category = category
        note.abv = {
            let v = Double(abvText)
            return (v != nil && v! >= 0 && v! <= 99.9) ? v : nil
        }()
        note.age = Int(ageText)
        note.price = Int(priceText)
        note.photoData = photoData
        note.rating = rating
        note.memo = memo
        note.dish = dish
        note.createdAt = existingNote?.createdAt ?? Date()

        if isEditMode {
            for fi in note.flavorIntensities { modelContext.delete(fi) }
        }
        for (name, intensity) in intensities where intensity > 0 {
            guard let flavorItem = FlavorConstants.all.first(where: { $0.name == name }) else { continue }
            let fi = FlavorIntensity(flavorType: flavorItem.type, name: name, intensity: intensity)
            fi.note = note
            note.flavorIntensities.append(fi)
            modelContext.insert(fi)
        }

        if !isEditMode { modelContext.insert(note) }
        dismiss()
    }
}

// MARK: - Edit Snapshot

private struct EditSnapshot {
    var name, category, abvText, ageText, priceText: String
    var photoData: Data?
    var intensities: [String: Int]
    var rating: Double
    var memo, dish: String
}
