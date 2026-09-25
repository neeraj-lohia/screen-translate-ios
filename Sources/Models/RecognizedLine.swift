import CoreGraphics
import Foundation

struct RecognizedLine: Identifiable {
    let id = UUID()
    let original: String
    /// Vision's normalized, bottom-left-origin bounding box (0...1 range).
    let boundingBox: CGRect
    var translated: String?
}

extension CGRect {
    /// Converts a Vision-space bounding box (normalized, origin bottom-left)
    /// into view-space coordinates for an image shown with `.scaledToFit()`
    /// inside `containerSize`.
    func toViewRect(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height

        var displayedSize = containerSize
        var offset = CGPoint.zero
        if imageAspect > containerAspect {
            displayedSize.height = containerSize.width / imageAspect
            offset.y = (containerSize.height - displayedSize.height) / 2
        } else {
            displayedSize.width = containerSize.height * imageAspect
            offset.x = (containerSize.width - displayedSize.width) / 2
        }

        let x = origin.x * displayedSize.width + offset.x
        let y = (1 - origin.y - height) * displayedSize.height + offset.y
        return CGRect(x: x, y: y, width: width * displayedSize.width, height: height * displayedSize.height)
    }
}
