# CLAUDE.md — QuickLookMax

Verbindliche Projektgesetze fuer QuickLookMax.
Dieses Dokument ist die einzige Wahrheit ueber Architektur, Regeln und Entscheidungen.
Lies es zuerst. Immer.

---

## 1. Was ist QuickLookMax?

QuickLookMax ist ein macOS Quick-Look-Erweiterungs-Tool.
Es erweitert Apples nativen Quick Look (Leertaste zum Vorschau) um mehr Dateitypen, bessere Vorschauen und eine verbesserte UX.

- **Lizenz:** Open Source (kostenlos)
- **Distribution:** GitHub + Homebrew Cask + npm (Tooling) + App Store
- **Zielplattform:** macOS
- **Installationsbefehl:** `brew install --cask quicklookmax`

---

## 2. Projektziele

- Maximale Dateityp-Abdeckung fuer Quick Look auf macOS
- Native Performance, keine Traegheit
- Einfachste Installation via Homebrew
- Entwickler-freundlich (Open Source, gut dokumentiert)
- Zero-Config fuer den Endnutzer

---

## 3. Absolute Projektgesetze

Diese Regeln gelten unveraendert. Ausnahmen muessen explizit begruendet und dokumentiert werden.

### 3.1 Architektur

- Eine zentrale Core-Datei pro Hauptmodul (kein Spaghetti-Code ueber viele kleine Dateien)
- Klare Trennung: Quick-Look-Extension-Logik | UI-Logik | Utilities
- Jede Klasse hat genau eine klar benannte Hauptverantwortung
- Keine doppelten Implementierungen — wiederholte Logik wird sofort zentralisiert
- OOP-Pflicht: Verhalten kapseln, Zustand bewusst verwalten

### 3.2 Sicherheit

- Keine Inline-Scripts in HTML-basierten Previews
- Untrusted Dateiinhalte werden nie direkt per `innerHTML` gerendert — immer `textContent` oder explizites Escaping
- Quick-Look-Extensions laufen in einer Sandbox — diese Sandbox-Grenzen niemals absichtlich umgehen
- Keine Netzwerkkommunikation in Quick-Look-Extensions (Apple-Policy + Sicherheitsprinzip)
- Benutzerdaten verlassen das System nicht

### 3.3 UI und Design

- Alle Farben, Abstaende, Radien und Schatten laufen ueber Design-Tokens
- Keine harten Einzelwerte im Code
- Previews folgen dem macOS-Systemdesign (Light/Dark Mode unterstuetzt von Anfang an)
- Kein inline-CSS-Chaos — eine zentrale CSS/Design-Datei pro Preview-Typ

### 3.4 Qualitaet

- Vor jedem groesseren Feature: bestehende Previews absichern
- Bugfixes fliessen als neue Regeln in dieses Dokument zurueck
- Keine stille Annahme ueber Dateiinhalt — defensives Parsen immer

---

## 4. Stack

| Bereich | Technologie |
|---|---|
| Hauptsprache | Swift |
| UI (native) | SwiftUI / AppKit |
| Quick-Look-Extension | `QLPreviewingController` (Swift) |
| HTML-basierte Previews | HTML + CSS + Vanilla JS (kein Framework) |
| Build | Xcode + Swift Package Manager |
| CI | GitHub Actions |
| Distribution | Homebrew Cask, GitHub Releases, (App Store optional) |
| Tooling/Scripts | Node.js / TypeScript (nur fuer Build-Tooling, nicht im App-Core) |

---

## 5. Projektstruktur (Ziel)

```
QuickLookMax/
├── QuickLookMax.xcodeproj/      # Xcode-Projekt
├── QuickLookMax/                # Haupt-App Target
│   ├── App/                     # AppDelegate, Entry Point
│   ├── Core/                    # Zentrale Business-Logik
│   ├── UI/                      # SwiftUI / AppKit Views
│   └── Resources/               # Assets, Localizations
├── QuickLookExtension/          # Quick-Look-Extension Target
│   ├── PreviewViewController.swift   # Haupt-Controller
│   ├── Renderers/               # Ein Renderer pro Dateityp
│   │   ├── MarkdownRenderer.swift
│   │   ├── JSONRenderer.swift
│   │   ├── CSVRenderer.swift
│   │   └── ...
│   ├── PreviewAssets/           # HTML/CSS/JS fuer Web-basierte Previews
│   │   ├── preview.html
│   │   ├── style.css
│   │   └── preview.js
│   └── Utilities/               # Shared Helpers
├── Scripts/                     # Build- und Release-Skripte (Node/Shell)
├── Tests/                       # Unit + Integration Tests
├── docs/                        # Dokumentation
├── CLAUDE.md                    # Dieses Dokument
├── STARTUP.md                   # Allgemeine Projektfibel
├── CHANGELOG.md                 # Entwicklungsgedaechtnis
└── README.md                    # Oeffentliche Doku
```

---

## 6. Renderer-Architektur

Jeder Dateityp bekommt einen eigenen, klar abgegrenzten Renderer.

### 6.1 Renderer-Protokoll (Swift)

```swift
protocol QuickLookRenderer {
    var supportedExtensions: [String] { get }
    var supportedMimeTypes: [String] { get }
    func render(url: URL, in view: NSView) throws
}
```

### 6.2 Renderer-Registrierung

- Eine zentrale `RendererRegistry` kennt alle Renderer
- Kein Switch-Statement-Chaos ausserhalb der Registry
- Neue Dateitypen: Renderer schreiben, in Registry eintragen — fertig

### 6.3 Aktuell geplante Renderer

| Dateityp | Status |
|---|---|
| Markdown (.md) | Geplant |
| JSON (.json) | Geplant |
| CSV (.csv) | Geplant |
| TOML (.toml) | Geplant |
| YAML (.yaml, .yml) | Geplant |
| SVG (.svg) | Geplant |
| Schriftarten (.ttf, .otf, .woff) | Geplant |
| Archive (.zip, .tar.gz) | Geplant |
| Source Code (diverse) | Geplant |
| Environment (.env) | Geplant |

---

## 7. HTML-basierte Previews — Sicherheitsregeln

Wenn ein Renderer HTML fuer die Vorschau nutzt:

- **Kein `innerHTML` mit ungeprueften Dateiinhalten**
- Dateiinhalt wird immer erst escaped, bevor er ins DOM geht
- Kein externes Laden von Ressourcen (`<script src="...">`, externe Fonts, etc.)
- Alle Assets (CSS, JS) sind lokal im Bundle
- JavaScript in Previews ist rein darstellend — keine Systemzugriffe

---

## 8. Design-Tokens fuer Previews

Alle HTML-Preview-Styles nutzen CSS-Variablen:

```css
:root {
  --qlm-bg: #ffffff;
  --qlm-text: #1a1a1a;
  --qlm-accent: #0066cc;
  --qlm-border: #e0e0e0;
  --qlm-code-bg: #f5f5f5;
  --qlm-radius: 6px;
  --qlm-spacing-sm: 8px;
  --qlm-spacing-md: 16px;
  --qlm-spacing-lg: 24px;
  --qlm-font-mono: "SF Mono", "Menlo", monospace;
  --qlm-font-ui: -apple-system, BlinkMacSystemFont, sans-serif;
}

@media (prefers-color-scheme: dark) {
  :root {
    --qlm-bg: #1e1e1e;
    --qlm-text: #d4d4d4;
    --qlm-border: #3a3a3a;
    --qlm-code-bg: #2a2a2a;
  }
}
```

---

## 9. Namenskonventionen

| Kontext | Stil | Beispiel |
|---|---|---|
| Swift-Klassen | PascalCase | `MarkdownRenderer` |
| Swift-Methoden | camelCase | `render(url:in:)` |
| Swift-Dateien | PascalCase | `RendererRegistry.swift` |
| CSS-Klassen | kebab-case mit `qlm-` Prefix | `qlm-code-block` |
| JS-Klassen | PascalCase | `PreviewController` |
| Branches | kebab-case | `feature/csv-renderer` |
| Tags/Releases | SemVer | `v1.0.0` |

---

## 10. Git-Workflow

- `main` ist immer stabil und releasebar
- Features auf `feature/*`-Branches
- Bugfixes auf `fix/*`-Branches
- Releases ueber Tags + GitHub Releases
- Commit-Messages auf Englisch, klar und praegnant
- Kein Force-Push auf `main`

---

## 11. Release-Prozess

1. Version in Xcode-Projekt erhoehen
2. `CHANGELOG.md` aktualisieren
3. Tag setzen: `git tag v1.x.x`
4. GitHub Release erstellen mit `.dmg` und `.zip`
5. Homebrew Cask-Formula aktualisieren (SHA256 + URL)
6. (Optional) App Store Update einreichen

---

## 12. Verbotene Praktiken

- Kein Polling oder Timer-basiertes Reloading in Previews
- Kein Netzwerkzugriff aus der Extension heraus
- Kein Lesen von Dateien ausserhalb der uebergebenen URL
- Kein Schreiben auf Disk aus der Extension
- Kein `innerHTML` mit ungeprueften Strings
- Kein Vendor-Lock-In in Kern-Logik
- Keine Magic Numbers — immer benannte Konstanten
- Kein Framework-Overkill fuer einfache HTML-Previews

---

## 13. Offene Entscheidungen (zu klaeren)

- [ ] App Store Verteilung: Sandbox-Restriktionen evaluieren
- [ ] Syntax-Highlighting Bibliothek: Highlight.js lokal gebundelt vs. eigene Implementierung
- [ ] Icon-Design und Branding festlegen
- [ ] Minimale macOS-Zielversion (aktuell: macOS 13+?)
- [ ] npm-Paket: Wofuer genau? (Tooling, CLI-Helper, oder doch nicht benoetigt?)

---

## 14. Start-Checkliste

### Phase 1: Fundament (aktuell)
- [x] STARTUP.md gelesen
- [x] CLAUDE.md angelegt
- [ ] GitHub Repo erstellt (Name gesichert!)
- [ ] Xcode-Projekt initialisiert mit zwei Targets (App + Extension)
- [ ] Grundstruktur angelegt (Ordner, leere Dateien)
- [ ] CHANGELOG.md angelegt
- [ ] README.md mit Kurzbeschreibung angelegt
- [ ] Homebrew Cask-Formula-Platzhalter erstellt
- [ ] GitHub Actions CI aufgesetzt (Build + Test)

### Phase 2: Erste Renderer
- [ ] RendererRegistry implementiert
- [ ] QuickLookRenderer-Protokoll definiert
- [ ] Markdown-Renderer (erster Renderer als Referenzimplementierung)
- [ ] JSON-Renderer
- [ ] Dark/Light Mode in Preview-Styles

### Phase 3: Distribution
- [ ] Erstes Release (.dmg) erstellen
- [ ] Homebrew Cask live schalten
- [ ] README vollstaendig

---

*Letzte Aktualisierung: 2026-04-03*
*Erstellt auf Basis von STARTUP.md*
