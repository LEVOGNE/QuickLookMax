import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("QuickLookMax")
                .font(.title)
                .fontWeight(.semibold)

            Text("Quick Look extension for developers.\nPress Space on any supported file in Finder.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            Text("Supported: Markdown · JSON · YAML · TOML · Source Code · SVG · Fonts · Archives · .env")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(width: 420)
    }
}
