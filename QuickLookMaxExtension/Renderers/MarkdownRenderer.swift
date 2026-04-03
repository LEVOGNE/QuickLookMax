import Foundation

final class MarkdownRenderer: QuickLookRenderer {

    var supportedExtensions: [String] { ["md", "markdown", "mdown", "mkd", "mkdn"] }

    func renderHTML(for url: URL) throws -> String {
        let raw = try String(contentsOf: url, encoding: .utf8)
        let body = convert(raw)
        return HTMLTemplate.wrap(title: url.lastPathComponent, body: body)
    }

    // MARK: - Markdown → HTML

    private func convert(_ markdown: String) -> String {
        var lines = markdown.components(separatedBy: "\n")
        var output = ""
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Fenced code block
            if line.hasPrefix("```") {
                let lang = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var code = ""
                i += 1
                while i < lines.count && !lines[i].hasPrefix("```") {
                    code += (code.isEmpty ? "" : "\n") + lines[i]
                    i += 1
                }
                let escaped = HTMLTemplate.escapeHTML(code)
                let langAttr = lang.isEmpty ? "" : " class=\"language-\(lang)\""
                output += "<pre><code\(langAttr)>\(escaped)</code></pre>\n"
                i += 1
                continue
            }

            // Setext h1
            if i + 1 < lines.count && lines[i + 1].hasPrefix("===") && !line.isEmpty {
                output += "<h1>\(inline(line))</h1>\n"
                i += 2; continue
            }
            // Setext h2
            if i + 1 < lines.count && lines[i + 1].hasPrefix("---") && !line.isEmpty {
                output += "<h2>\(inline(line))</h2>\n"
                i += 2; continue
            }

            // ATX headers
            if line.hasPrefix("#### ") { output += "<h4>\(inline(String(line.dropFirst(5))))</h4>\n"; i += 1; continue }
            if line.hasPrefix("### ")  { output += "<h3>\(inline(String(line.dropFirst(4))))</h3>\n"; i += 1; continue }
            if line.hasPrefix("## ")   { output += "<h2>\(inline(String(line.dropFirst(3))))</h2>\n"; i += 1; continue }
            if line.hasPrefix("# ")    { output += "<h1>\(inline(String(line.dropFirst(2))))</h1>\n"; i += 1; continue }

            // Horizontal rule
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                output += "<hr>\n"; i += 1; continue
            }

            // Blockquote
            if line.hasPrefix("> ") {
                var quote = ""
                while i < lines.count && lines[i].hasPrefix("> ") {
                    quote += (quote.isEmpty ? "" : "\n") + String(lines[i].dropFirst(2))
                    i += 1
                }
                output += "<blockquote><p>\(inline(quote))</p></blockquote>\n"
                continue
            }

            // Unordered list
            if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                output += "<ul>\n"
                while i < lines.count && (lines[i].hasPrefix("- ") || lines[i].hasPrefix("* ") || lines[i].hasPrefix("+ ")) {
                    output += "  <li>\(inline(String(lines[i].dropFirst(2))))</li>\n"
                    i += 1
                }
                output += "</ul>\n"
                continue
            }

            // Ordered list
            if let _ = line.range(of: #"^\d+\. "#, options: .regularExpression) {
                output += "<ol>\n"
                while i < lines.count,
                      let range = lines[i].range(of: #"^\d+\. "#, options: .regularExpression) {
                    let text = String(lines[i][range.upperBound...])
                    output += "  <li>\(inline(text))</li>\n"
                    i += 1
                }
                output += "</ol>\n"
                continue
            }

            // Table (simple: | col | col |)
            if line.hasPrefix("|") {
                var tableLines: [String] = []
                while i < lines.count && lines[i].hasPrefix("|") {
                    tableLines.append(lines[i])
                    i += 1
                }
                output += buildTable(tableLines)
                continue
            }

            // Empty line
            if trimmed.isEmpty {
                output += "\n"
                i += 1; continue
            }

            // Paragraph
            var para = ""
            while i < lines.count {
                let l = lines[i]
                let t = l.trimmingCharacters(in: .whitespaces)
                if t.isEmpty || l.hasPrefix("#") || l.hasPrefix(">") || l.hasPrefix("- ")
                    || l.hasPrefix("* ") || l.hasPrefix("+ ") || l.hasPrefix("```")
                    || l.hasPrefix("|") { break }
                para += (para.isEmpty ? "" : " ") + l
                i += 1
            }
            if !para.isEmpty {
                output += "<p>\(inline(para))</p>\n"
            }
        }

        return output
    }

    // MARK: - Inline formatting

    private func inline(_ text: String) -> String {
        var s = HTMLTemplate.escapeHTML(text)
        // Bold + italic combined
        s = replace(s, pattern: #"\*\*\*(.+?)\*\*\*"#, with: "<strong><em>$1</em></strong>")
        // Bold
        s = replace(s, pattern: #"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>")
        s = replace(s, pattern: #"__(.+?)__"#,     with: "<strong>$1</strong>")
        // Italic
        s = replace(s, pattern: #"\*(.+?)\*"#, with: "<em>$1</em>")
        s = replace(s, pattern: #"_(.+?)_"#,   with: "<em>$1</em>")
        // Inline code
        s = replace(s, pattern: #"`(.+?)`"#, with: "<code>$1</code>")
        // Image (before link)
        s = replace(s, pattern: #"!\[([^\]]*)\]\(([^)]+)\)"#, with: "<img src=\"$2\" alt=\"$1\" style=\"max-width:100%\">")
        // Link
        s = replace(s, pattern: #"\[([^\]]+)\]\(([^)]+)\)"#, with: "<a href=\"$2\">$1</a>")
        // Strikethrough
        s = replace(s, pattern: #"~~(.+?)~~"#, with: "<del>$1</del>")
        return s
    }

    private func replace(_ s: String, pattern: String, with template: String) -> String {
        (try? NSRegularExpression(pattern: pattern, options: []))
            .map { $0.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: template) }
            ?? s
    }

    // MARK: - Table

    private func buildTable(_ lines: [String]) -> String {
        guard lines.count >= 2 else { return "" }
        func cells(_ line: String) -> [String] {
            line.split(separator: "|", omittingEmptySubsequences: false)
                .dropFirst().dropLast()
                .map { $0.trimmingCharacters(in: .whitespaces) }
        }
        var html = "<table>\n<thead>\n<tr>"
        for cell in cells(lines[0]) { html += "<th>\(inline(cell))</th>" }
        html += "</tr>\n</thead>\n<tbody>\n"
        for line in lines.dropFirst(2) {
            html += "<tr>"
            for cell in cells(line) { html += "<td>\(inline(cell))</td>" }
            html += "</tr>\n"
        }
        html += "</tbody>\n</table>\n"
        return html
    }
}
