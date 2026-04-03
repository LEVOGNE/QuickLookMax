import Foundation

final class SourceCodeRenderer: QuickLookRenderer {

    var supportedExtensions: [String] {
        ["swift", "ts", "tsx", "js", "jsx", "py", "rb", "go", "rs",
         "c", "h", "cpp", "cxx", "cc", "m", "mm", "java", "kt", "cs",
         "sh", "bash", "zsh", "fish", "ps1",
         "css", "scss", "less",
         "html", "htm", "svg", "xml",
         "yaml", "yml", "toml", "ini", "conf", "cfg",
         "env", "envrc",
         "dockerfile", "containerfile",
         "makefile", "cmake",
         "sql", "graphql", "gql",
         "r", "lua", "dart", "ex", "exs", "erl",
         "tf", "tfvars", "hcl",
         "log"]
    }

    func renderHTML(for url: URL) throws -> String {
        let raw = try String(contentsOf: url, encoding: .utf8)
        let lang = language(for: url.pathExtension.lowercased(), name: url.lastPathComponent.lowercased())
        let highlighted = highlight(raw, language: lang)
        let header = "<div class=\"file-header\">\(HTMLTemplate.escapeHTML(url.lastPathComponent))</div>"
        let body = "\(header)<pre><code>\(highlighted)</code></pre>"
        return HTMLTemplate.wrap(title: url.lastPathComponent, body: body, bodyClass: "code")
    }

    // MARK: - Language detection

    private func language(for ext: String, name: String) -> String {
        switch ext {
        case "swift":                          return "swift"
        case "ts", "tsx":                      return "typescript"
        case "js", "jsx":                      return "javascript"
        case "py":                             return "python"
        case "rb":                             return "ruby"
        case "go":                             return "go"
        case "rs":                             return "rust"
        case "c", "h":                         return "c"
        case "cpp", "cxx", "cc", "mm":        return "cpp"
        case "m":                              return "objc"
        case "java":                           return "java"
        case "kt":                             return "kotlin"
        case "cs":                             return "csharp"
        case "sh", "bash", "zsh", "fish":     return "shell"
        case "ps1":                            return "powershell"
        case "css", "scss", "less":            return "css"
        case "html", "htm":                    return "html"
        case "xml":                            return "xml"
        case "svg":                            return "xml"
        case "yaml", "yml":                    return "yaml"
        case "toml":                           return "toml"
        case "sql":                            return "sql"
        case "graphql", "gql":                 return "graphql"
        case "tf", "tfvars", "hcl":           return "hcl"
        case "":
            if name == "dockerfile" || name == "containerfile" { return "dockerfile" }
            if name == "makefile"   { return "makefile" }
            return "text"
        default:                               return "text"
        }
    }

    // MARK: - Highlighter

    private func highlight(_ code: String, language: String) -> String {
        let keywords = keywordSet(for: language)
        var result = ""
        var i = code.startIndex

        while i < code.endIndex {
            // Single-line comment
            if let (token, next) = matchSingleLineComment(code, at: i, language: language) {
                result += "<span class=\"cmt\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next; continue
            }
            // Multi-line comment
            if let (token, next) = matchMultiLineComment(code, at: i, language: language) {
                result += "<span class=\"cmt\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next; continue
            }
            // String (double-quoted)
            if code[i] == "\"" {
                let (token, next) = readQuoted(code, from: i, quote: "\"")
                result += "<span class=\"str\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next; continue
            }
            // String (single-quoted) — not for Rust lifetimes
            if code[i] == "'" && language != "rust" {
                let (token, next) = readQuoted(code, from: i, quote: "'")
                result += "<span class=\"str\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next; continue
            }
            // Backtick string (JS/TS template literals)
            if code[i] == "`" && (language == "javascript" || language == "typescript") {
                let (token, next) = readQuoted(code, from: i, quote: "`")
                result += "<span class=\"str\">\(HTMLTemplate.escapeHTML(token))</span>"
                i = next; continue
            }
            // Number
            if code[i].isNumber {
                var num = ""
                var j = i
                while j < code.endIndex && (code[j].isNumber || code[j] == "." || code[j] == "x" || code[j] == "b" || "abcdefABCDEF_".contains(code[j])) {
                    num.append(code[j])
                    j = code.index(after: j)
                }
                result += "<span class=\"num\">\(HTMLTemplate.escapeHTML(num))</span>"
                i = j; continue
            }
            // Identifier / keyword
            if code[i].isLetter || code[i] == "_" || code[i] == "@" || code[i] == "#" {
                var word = ""
                var j = i
                while j < code.endIndex && (code[j].isLetter || code[j].isNumber || code[j] == "_") {
                    word.append(code[j])
                    j = code.index(after: j)
                }
                // Check next non-space char for function detection
                let lookAhead = code[j...].drop(while: { $0 == " " || $0 == "\t" }).first
                let escaped = HTMLTemplate.escapeHTML(word)
                if keywords.contains(word) {
                    result += "<span class=\"kw\">\(escaped)</span>"
                } else if lookAhead == "(" {
                    result += "<span class=\"fn\">\(escaped)</span>"
                } else if word.first?.isUppercase == true {
                    result += "<span class=\"typ\">\(escaped)</span>"
                } else {
                    result += escaped
                }
                i = j; continue
            }
            // Everything else
            result += HTMLTemplate.escapeHTML(String(code[i]))
            i = code.index(after: i)
        }
        return result
    }

    // MARK: - Comment matchers

    private func matchSingleLineComment(_ s: String, at i: String.Index, language: String) -> (String, String.Index)? {
        let markers: [String]
        switch language {
        case "python", "ruby", "shell", "makefile", "dockerfile", "toml", "yaml": markers = ["#"]
        case "sql":   markers = ["--"]
        case "css":   markers = []
        case "html":  markers = []
        default:      markers = ["//"]
        }
        for m in markers {
            if s[i...].hasPrefix(m) {
                var j = i
                while j < s.endIndex && s[j] != "\n" { j = s.index(after: j) }
                return (String(s[i..<j]), j)
            }
        }
        return nil
    }

    private func matchMultiLineComment(_ s: String, at i: String.Index, language: String) -> (String, String.Index)? {
        let (open, close): (String, String)
        switch language {
        case "html":  (open, close) = ("<!--", "-->")
        case "css":   (open, close) = ("/*", "*/")
        case "sql":   (open, close) = ("/*", "*/")
        case "python", "ruby", "shell", "yaml", "toml": return nil
        default:      (open, close) = ("/*", "*/")
        }
        guard s[i...].hasPrefix(open) else { return nil }
        var j = s.index(i, offsetBy: open.count)
        while j < s.endIndex {
            if s[j...].hasPrefix(close) {
                j = s.index(j, offsetBy: close.count)
                return (String(s[i..<j]), j)
            }
            j = s.index(after: j)
        }
        return (String(s[i...]), s.endIndex)
    }

    // MARK: - String reader

    private func readQuoted(_ s: String, from start: String.Index, quote: Character) -> (String, String.Index) {
        var i = s.index(after: start)
        var token = String(quote)
        while i < s.endIndex {
            let c = s[i]
            token.append(c)
            if c == "\\" && s.index(after: i) < s.endIndex {
                i = s.index(after: i)
                token.append(s[i])
            } else if c == quote {
                return (token, s.index(after: i))
            }
            i = s.index(after: i)
        }
        return (token, i)
    }

    // MARK: - Keyword sets

    private func keywordSet(for language: String) -> Set<String> {
        switch language {
        case "swift":
            return ["class","struct","enum","protocol","extension","func","var","let","if","else",
                    "guard","switch","case","default","for","while","repeat","return","throw","throws",
                    "try","catch","do","import","typealias","associatedtype","init","deinit","super",
                    "self","static","final","open","public","internal","fileprivate","private","mutating",
                    "override","lazy","weak","unowned","inout","async","await","actor","nonisolated",
                    "true","false","nil","in","where","as","is","any","some","Type"]
        case "typescript", "javascript":
            return ["const","let","var","function","class","extends","implements","interface","type",
                    "enum","if","else","for","while","do","return","throw","try","catch","finally",
                    "async","await","import","export","from","default","new","typeof","instanceof",
                    "void","null","undefined","true","false","this","super","static","public",
                    "private","protected","readonly","abstract","override","in","of","break","continue",
                    "switch","case","yield","get","set","as","satisfies","keyof","infer","never","unknown","any"]
        case "python":
            return ["def","class","if","elif","else","for","while","return","import","from","as",
                    "with","try","except","finally","raise","pass","break","continue","yield",
                    "lambda","and","or","not","in","is","True","False","None","async","await",
                    "global","nonlocal","assert","del","property","staticmethod","classmethod"]
        case "go":
            return ["func","var","const","type","struct","interface","map","chan","package","import",
                    "if","else","for","range","return","switch","case","default","select","go",
                    "defer","break","continue","fallthrough","goto","nil","true","false","make",
                    "new","len","cap","append","copy","delete","panic","recover","error","string",
                    "int","int8","int16","int32","int64","uint","uint8","uint16","uint32","uint64",
                    "float32","float64","bool","byte","rune","any"]
        case "rust":
            return ["fn","let","mut","const","static","struct","enum","trait","impl","use","mod",
                    "pub","crate","super","self","if","else","match","for","while","loop","return",
                    "break","continue","where","type","as","in","ref","move","async","await","dyn",
                    "extern","unsafe","true","false","None","Some","Ok","Err","Box","Vec","String",
                    "Option","Result","i8","i16","i32","i64","i128","u8","u16","u32","u64","u128",
                    "f32","f64","bool","char","str","usize","isize"]
        case "java", "kotlin", "csharp":
            return ["class","interface","extends","implements","public","private","protected",
                    "static","final","void","return","if","else","for","while","do","switch","case",
                    "break","continue","new","this","super","import","package","try","catch","finally",
                    "throw","throws","null","true","false","int","long","double","float","boolean",
                    "char","byte","short","abstract","synchronized","volatile","native","transient",
                    "var","val","fun","object","companion","data","sealed","override","open","when","in"]
        case "sql":
            return ["SELECT","FROM","WHERE","JOIN","LEFT","RIGHT","INNER","OUTER","ON","GROUP","BY",
                    "ORDER","HAVING","LIMIT","OFFSET","INSERT","INTO","VALUES","UPDATE","SET","DELETE",
                    "CREATE","TABLE","INDEX","VIEW","DROP","ALTER","ADD","COLUMN","PRIMARY","KEY",
                    "FOREIGN","REFERENCES","UNIQUE","NOT","NULL","AND","OR","IN","LIKE","BETWEEN",
                    "EXISTS","CASE","WHEN","THEN","ELSE","END","AS","DISTINCT","COUNT","SUM","AVG",
                    "MAX","MIN","COALESCE","WITH","RETURNING","BEGIN","COMMIT","ROLLBACK","TRANSACTION"]
        case "shell":
            return ["if","then","else","elif","fi","for","in","do","done","while","until","case",
                    "esac","function","return","exit","echo","export","source","local","readonly",
                    "shift","set","unset","true","false","break","continue"]
        case "css":
            return ["important","var","calc","inherit","initial","unset","none","auto","normal",
                    "flex","grid","block","inline","absolute","relative","fixed","sticky"]
        default:
            return []
        }
    }
}
