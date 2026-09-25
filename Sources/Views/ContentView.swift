import PhotosUI
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var pending: PendingScreenshot
    @State private var pickerItem: PhotosPickerItem?
    @State private var pickedImage: UIImage?

    var body: some View {
        Group {
            if let image = pending.image {
                TranslateOverlayView(image: image) {
                    pending.image = nil
                }
            } else if let pickedImage {
                TranslateOverlayView(image: pickedImage) {
                    self.pickedImage = nil
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "character.bubble")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                    Text("ScreenTranslate")
                        .font(.title2.bold())
                    Text("Press your Action Button shortcut (Take Screenshot \u{2192} Translate Screenshot) from any app to translate what's on screen.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)

                    PhotosPicker("Or pick a photo to test", selection: $pickerItem, matching: .images)
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    pickedImage = UIImage(data: data)
                }
            }
        }
    }
}
