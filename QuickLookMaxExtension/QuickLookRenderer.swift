import Foundation

/// Protocol every file-type renderer must implement.
protocol QuickLookRenderer {
    /// File extensions this renderer handles (lowercase, without dot).
    var supportedExtensions: [String] { get }

    /// Returns a complete HTML document string for the given file.
    func renderHTML(for url: URL) throws -> String
}
