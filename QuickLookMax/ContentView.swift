import SwiftUI

struct ContentView: View {

    @State private var nativeDisabled: Bool = false
    @State private var statusMessage: String = ""

    private let systemExtensionID = "com.apple.QuickLookUIFramework.QLPreviewGenerationExtension"
    private let ourExtensionID    = "com.quicklookmax.app.extension"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ───────────────────────────────────────────────
            HStack(spacing: 14) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text("QuickLookMax")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Quick Look extension for developers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(24)

            Divider()

            // ── Settings ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 16) {

                Label("Extension Settings", systemImage: "puzzlepiece.extension")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)

                // Native toggle
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Disable native Quick Look")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("Turns off macOS's built-in text renderer so QuickLookMax handles all supported files exclusively.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $nativeDisabled)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .onChange(of: nativeDisabled) { _, newValue in
                            applyNativeSetting(disabled: newValue)
                        }
                }
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))

                // Status message
                if !statusMessage.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity)
                }
            }
            .padding(24)

            Divider()

            // ── Supported file types ─────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                Label("Supported file types", systemImage: "doc.text")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                let types: [(String, String)] = [
                    ("Markdown",        ".md .markdown"),
                    ("Data",            ".json .yaml .toml .csv .xml"),
                    ("Config & env",    ".env .ini .conf .editorconfig"),
                    ("Source code",     ".swift .ts .py .go .rs .sh …"),
                    ("Web",             ".html .css .svg"),
                    ("Plain text",      ".txt .log"),
                ]

                ForEach(types, id: \.0) { label, exts in
                    HStack {
                        Text(label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(width: 90, alignment: .leading)
                        Text(exts)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(24)
        }
        .frame(width: 420)
        .onAppear { readCurrentState() }
        .animation(.easeInOut(duration: 0.2), value: statusMessage)
    }

    // MARK: - pluginkit helpers

    private func readCurrentState() {
        // If our extension is in the active list, and system one is absent → native is disabled
        let activeIDs = runPluginkit(["-m", "-p", "com.apple.quicklook.preview"])
        nativeDisabled = !activeIDs.contains(systemExtensionID)
    }

    private func applyNativeSetting(disabled: Bool) {
        if disabled {
            run("/usr/bin/pluginkit", ["-e", "ignore", "-i", systemExtensionID])
            run("/usr/bin/pluginkit", ["-e", "use",    "-i", ourExtensionID])
        } else {
            run("/usr/bin/pluginkit", ["-e", "use", "-i", systemExtensionID])
        }
        run("/usr/bin/qlmanage", ["-r"])
        run("/usr/bin/qlmanage", ["-r", "cache"])

        withAnimation {
            statusMessage = disabled
                ? "Native Quick Look disabled — QuickLookMax is now exclusive."
                : "Native Quick Look re-enabled."
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { statusMessage = "" }
        }
    }

    @discardableResult
    private func runPluginkit(_ args: [String]) -> String {
        run("/usr/bin/pluginkit", args)
    }

    @discardableResult
    private func run(_ executable: String, _ args: [String]) -> String {
        let p = Process()
        let pipe = Pipe()
        p.executableURL = URL(fileURLWithPath: executable)
        p.arguments = args
        p.standardOutput = pipe
        p.standardError = pipe
        try? p.run()
        p.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}
