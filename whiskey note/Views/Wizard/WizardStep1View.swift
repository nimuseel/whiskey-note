import SwiftUI
import PhotosUI

struct WizardStep1View: View {
    @Binding var name: String
    @Binding var category: String
    @Binding var abv: String
    @Binding var age: String
    @Binding var price: String
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var photoData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 사진 영역
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Group {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.tagBackground)
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .overlay {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.largeTitle)
                                            .foregroundStyle(AppColors.accent)
                                        Text("사진 추가 (선택)")
                                            .font(.subheadline)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                        }
                    }
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            photoData = compressImage(data)
                        }
                    }
                }

                // 기본 정보 폼
                VStack(spacing: 12) {
                    formField(label: "위스키 이름 *") {
                        TextField("예: Laphroaig 10yr", text: $name)
                            .accessibilityIdentifier("nameField")
                    }

                    formField(label: "종류") {
                        Picker("종류", selection: $category) {
                            ForEach(WhiskeyCategory.allCases, id: \.rawValue) { cat in
                                Text(cat.localizedName).tag(cat.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack(spacing: 12) {
                        formField(label: "도수 (%)") {
                            TextField("예: 43.0", text: $abv)
                                .keyboardType(.decimalPad)
                                .accessibilityIdentifier("abvField")
                        }
                        formField(label: "숙성 연수") {
                            TextField("예: 10", text: $age)
                                .keyboardType(.numberPad)
                                .accessibilityIdentifier("ageField")
                        }
                    }

                    formField(label: "가격 (원)") {
                        TextField("예: 80000", text: $price)
                            .keyboardType(.numberPad)
                            .accessibilityIdentifier("priceField")
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func formField<Content: View>(label: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            content()
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

    private func compressImage(_ data: Data) -> Data {
        guard let uiImage = UIImage(data: data) else { return data }
        let maxSize: CGFloat = 800
        let scale = min(maxSize / uiImage.size.width, maxSize / uiImage.size.height, 1.0)
        let newSize = CGSize(width: uiImage.size.width * scale, height: uiImage.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in uiImage.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.8) ?? data
    }
}

