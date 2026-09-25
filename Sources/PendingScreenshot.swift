import SwiftUI

/// Bridges an image handed to us by `TranslateScreenshotIntent` (invoked from
/// the Shortcuts app / Action Button) into the SwiftUI view hierarchy.
final class PendingScreenshot: ObservableObject {
    static let shared = PendingScreenshot()

    @Published var image: UIImage?

    private init() {}
}
