import AppIntents
import UIKit

/// Entry point invoked from a Shortcut (e.g. "Take Screenshot" -> "Translate
/// Screenshot") that can be bound to the iPhone Action Button. Receives the
/// image, stashes it for the UI, and foregrounds the app to show the
/// translated overlay.
struct TranslateScreenshotIntent: AppIntent {
    static var title: LocalizedStringResource = "Translate Screenshot"
    static var description = IntentDescription(
        "Runs on-device OCR + translation over an image (e.g. from \"Take Screenshot\") and shows translated text overlaid on top of it."
    )
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Image", supportedContentTypes: [.image])
    var image: IntentFile

    @MainActor
    func perform() async throws -> some IntentResult {
        let data = try image.data
        if let uiImage = UIImage(data: data) {
            PendingScreenshot.shared.image = uiImage
        }
        return .result()
    }
}
