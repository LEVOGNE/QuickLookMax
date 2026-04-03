import Foundation

/// Fallback renderer for any text file that has no dedicated renderer.
final class PlainTextRenderer: QuickLookRenderer {

    var supportedExtensions: [String] { ["txt", "text", "nfo", "rtf", "csv", "tsv"] }

    func renderHTML(for url: URL) throws -> String {
        let raw = try String(contentsOf: url, encoding: .utf8)
        let escaped = HTMLTemplate.escapeHTML(raw)
        let header = "<div class=\"file-header\">\(HTMLTemplate.escapeHTML(url.lastPathComponent))</div>"
        let body = "\(header)<pre><code>\(escaped)</code></pre>"
        return HTMLTemplate.wrap(title: url.lastPathComponent, body: body, bodyClass: "code")
    }
}
