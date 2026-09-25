import SwiftUI
import Translation

/// Shows the (frozen) screenshot full-screen and overlays translated text
/// directly on top of each recognized line, mimicking Android's
/// Circle-to-Search style in-place translation.
struct TranslateOverlayView: View {
    let image: UIImage
    var onClose: () -> Void

    @State private var lines: [RecognizedLine] = []
    @State private var isProcessing = true
    @State private var configuration: TranslationSession.Configuration?
    @State private var errorMessage: String?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)

                ForEach(lines) { line in
                    let rect = line.boundingBox.toViewRect(imageSize: image.size, containerSize: geo.size)
                    ZStack {
                        Rectangle().fill(Color.black.opacity(0.88))
                        Text(line.translated ?? line.original)
                            .font(.system(size: max(9, rect.height * 0.62)))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                            .padding(.horizontal, 2)
                    }
                    .frame(width: max(rect.width, 4), height: max(rect.height, 4))
                    .position(x: rect.midX, y: rect.midY)
                    .opacity(line.translated == nil && isProcessing ? 0.0 : 1.0)
                }

                if isProcessing {
                    ProgressView("Reading & translating\u{2026}")
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                VStack {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.white, .black.opacity(0.6))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
        .task { await runOCR() }
        .translationTask(configuration) { session in
            await translateLines(using: session)
        }
        .alert("Something went wrong", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
                onClose()
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func runOCR() async {
        do {
            let recognized = try await OCRTranslator.recognizeText(in: image)
            lines = recognized
            guard !recognized.isEmpty else {
                isProcessing = false
                return
            }
            configuration = TranslationSession.Configuration(
                source: Locale.Language(identifier: "de"),
                target: Locale.Language(identifier: "en")
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func translateLines(using session: TranslationSession) async {
        do {
            let requests = lines.map {
                TranslationSession.Request(sourceText: $0.original, clientIdentifier: $0.id.uuidString)
            }
            let responses = try await session.translations(from: requests)
            for response in responses {
                guard let clientIdentifier = response.clientIdentifier,
                      let idx = lines.firstIndex(where: { $0.id.uuidString == clientIdentifier }) else { continue }
                lines[idx].translated = response.targetText
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }
}
