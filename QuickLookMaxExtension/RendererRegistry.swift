import Foundation

/// Central registry: maps file extensions to the right renderer.
final class RendererRegistry {

    static let shared = RendererRegistry()

    private let renderers: [QuickLookRenderer] = [
        MarkdownRenderer(),
        JSONRenderer(),
        SourceCodeRenderer(),
        PlainTextRenderer(),   // fallback — must be last
    ]

    private init() {}

    func render(url: URL) throws -> String {
        let ext = url.pathExtension.lowercased()
        let renderer = renderers.first { $0.supportedExtensions.contains(ext) }
            ?? PlainTextRenderer()
        return try renderer.renderHTML(for: url)
    }
}
