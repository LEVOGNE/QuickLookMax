import Foundation

final class JSONRenderer: QuickLookRenderer {

    var supportedExtensions: [String] { ["json", "jsonc", "geojson"] }

    func renderHTML(for url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let prettyJSON: String

        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let pretty = try JSONSerialization.data(
                withJSONObject: obj,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            )
            prettyJSON = String(data: pretty, encoding: .utf8) ?? (String(data: data, encoding: .utf8) ?? "")
        } catch {
            // Not valid JSON — show raw with error hint
            let raw = String(data: data, encoding: .utf8) ?? "(binary data)"
            let escaped = HTMLTemplate.escapeHTML(raw)
            let err = HTMLTemplate.escapeHTML(error.localizedDescription)
            let body = """
            <p style="color:var(--str);margin-bottom:12px">⚠️ Invalid JSON: \(err)</p>
            <pre><code>\(escaped)</code></pre>
            """
            return HTMLTemplate.wrap(title: url.lastPathComponent, body: body)
        }

        let highlighted = highlightJSON(prettyJSON)
        let header = "<div class=\"file-header\">\(HTMLTemplate.escapeHTML(url.lastPathComponent))</div>"
        let body = "\(header)<pre><code>\(highlighted)</code></pre>"
        return HTMLTemplate.wrap(title: url.lastPathComponent, body: body, bodyClass: "code")
    }

    // MARK: - JSON syntax highlighting

    private func highlightJSON(_ json: String) -> String {
        var result = ""
        var i = json.startIndex

        while i < json.endIndex {
            let ch = json[i]

            // String
            if ch == "\"" {
                let (token, next) = readString(json, from: i)
                // Determine if this is a key (followed by : after optional whitespace)
                let rest = json[next...].drop(while: { $0 == " " })
                let isKey = rest.first == ":"
                let cls = isKey ? "json-key" : "json-str"
                result += "<span class=\"\(cls)\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next
                continue
            }

            // Number
            if ch.isNumber || (ch == "-" && json.index(after: i) < json.endIndex && json[json.index(after: i)].isNumber) {
                var num = String(ch)
                var j = json.index(after: i)
                while j < json.endIndex && (json[j].isNumber || json[j] == "." || json[j] == "e" || json[j] == "E" || json[j] == "+" || json[j] == "-") {
                    num.append(json[j])
                    j = json.index(after: j)
                }
                result += "<span class=\"json-num\">\(HTMLTemplate.escapeHTML(num))</span>"
                i = j
                continue
            }

            // true / false / null
            for keyword in ["true", "false", "null"] {
                if json[i...].hasPrefix(keyword) {
                    let cls = keyword == "null" ? "json-null" : "json-bool"
                    result += "<span class=\"\(cls)\">\(keyword)</span>"
                    i = json.index(i, offsetBy: keyword.count)
                    break
                }
                continue
            }

            // Everything else (braces, brackets, colons, commas, whitespace)
            result += HTMLTemplate.escapeHTML(String(ch))
            i = json.index(after: i)
        }

        return result
    }

    /// Reads a quoted JSON string, returns (rawString, nextIndex).
    private func readString(_ s: String, from start: String.Index) -> (String, String.Index) {
        var i = s.index(after: start) // skip opening "
        var token = "\""
        while i < s.endIndex {
            let c = s[i]
            token.append(c)
            if c == "\\" && s.index(after: i) < s.endIndex {
                i = s.index(after: i)
                token.append(s[i])
            } else if c == "\"" {
                i = s.index(after: i)
                return (token, i)
            }
            i = s.index(after: i)
        }
        return (token, i)
    }
}
