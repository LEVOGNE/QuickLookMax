import Foundation

/// Builds the outer HTML shell injected into the WKWebView.
enum HTMLTemplate {

    static func wrap(title: String, body: String, bodyClass: String = "") -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="color-scheme" content="light dark">
        <title>\(escapeHTML(title))</title>
        <style>\(css)</style>
        </head>
        <body class="\(bodyClass)">
        \(body)
        </body>
        </html>
        """
    }

    static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    // MARK: - CSS

    private static let css = """
    :root {
        --bg:         #ffffff;
        --bg-2:       #f5f5f7;
        --text:       #1d1d1f;
        --text-2:     #6e6e73;
        --border:     #d2d2d7;
        --accent:     #0071e3;
        --code-bg:    #f0f0f2;
        --pre-bg:     #1e1e2e;
        --pre-text:   #cdd6f4;
        --kw:         #0550ae;
        --str:        #0a3069;
        --cmt:        #6e6e73;
        --num:        #0550ae;
        --fn:         #8250df;
        --type:       #953800;
    }
    @media (prefers-color-scheme: dark) {
        :root {
            --bg:     #1c1c1e;
            --bg-2:   #2c2c2e;
            --text:   #f5f5f7;
            --text-2: #98989d;
            --border: #3a3a3c;
            --accent: #2997ff;
            --code-bg:#2c2c2e;
            --pre-bg: #161620;
            --pre-text:#cdd6f4;
            --kw:     #79c0ff;
            --str:    #a5d6ff;
            --cmt:    #8b949e;
            --num:    #79c0ff;
            --fn:     #d2a8ff;
            --type:   #ffa657;
        }
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { font-size: 14px; }
    body {
        background: var(--bg);
        color: var(--text);
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
        line-height: 1.6;
        padding: 24px 28px;
        max-width: 900px;
    }
    /* --- Markdown / prose --- */
    h1,h2,h3,h4,h5,h6 {
        font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", sans-serif;
        font-weight: 600;
        line-height: 1.3;
        margin: 1.4em 0 0.4em;
    }
    h1 { font-size: 1.9em; border-bottom: 1px solid var(--border); padding-bottom: 0.3em; }
    h2 { font-size: 1.4em; border-bottom: 1px solid var(--border); padding-bottom: 0.2em; }
    h3 { font-size: 1.15em; }
    p { margin: 0.7em 0; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    strong { font-weight: 600; }
    em { font-style: italic; }
    ul, ol { margin: 0.6em 0 0.6em 1.6em; }
    li { margin: 0.2em 0; }
    blockquote {
        border-left: 3px solid var(--border);
        margin: 0.8em 0;
        padding: 0.2em 1em;
        color: var(--text-2);
    }
    hr { border: none; border-top: 1px solid var(--border); margin: 1.4em 0; }
    code {
        font-family: "SF Mono", Menlo, Monaco, "Courier New", monospace;
        font-size: 0.88em;
        background: var(--code-bg);
        border-radius: 4px;
        padding: 0.15em 0.4em;
    }
    /* --- Code blocks --- */
    pre {
        background: var(--pre-bg);
        color: var(--pre-text);
        border-radius: 8px;
        padding: 16px 18px;
        overflow-x: auto;
        margin: 0.9em 0;
        font-family: "SF Mono", Menlo, Monaco, "Courier New", monospace;
        font-size: 0.85em;
        line-height: 1.55;
    }
    pre code {
        background: none;
        padding: 0;
        font-size: inherit;
        color: inherit;
        border-radius: 0;
    }
    /* --- Syntax tokens --- */
    .kw  { color: var(--kw);   font-weight: 600; }
    .str { color: var(--str);  }
    .cmt { color: var(--cmt);  font-style: italic; }
    .num { color: var(--num);  }
    .fn  { color: var(--fn);   }
    .typ { color: var(--type); }
    /* --- JSON --- */
    .json-key   { color: var(--fn); }
    .json-str   { color: var(--str); }
    .json-num   { color: var(--num); }
    .json-bool  { color: var(--kw);  font-weight: 600; }
    .json-null  { color: var(--cmt); font-style: italic; }
    /* --- Full-file code view --- */
    body.code {
        padding: 0;
        max-width: 100%;
    }
    body.code pre {
        border-radius: 0;
        min-height: 100vh;
        margin: 0;
        padding: 20px 24px;
    }
    /* --- Tables (for markdown) --- */
    table { border-collapse: collapse; width: 100%; margin: 0.8em 0; font-size: 0.9em; }
    th, td { border: 1px solid var(--border); padding: 6px 12px; text-align: left; }
    th { background: var(--bg-2); font-weight: 600; }
    tr:nth-child(even) td { background: var(--bg-2); }
    /* --- File header (used in plain text / code) --- */
    .file-header {
        font-size: 0.78em;
        color: var(--text-2);
        margin-bottom: 8px;
        font-family: "SF Mono", Menlo, monospace;
    }
    """
}
