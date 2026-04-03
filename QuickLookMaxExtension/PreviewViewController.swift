import Cocoa
import Quartz
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!

    // MARK: - View lifecycle

    override func loadView() {
        let config = WKWebViewConfiguration()
        // No JS needed — pure HTML/CSS rendering
        config.defaultWebpagePreferences.allowsContentJavaScript = false

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    // MARK: - QLPreviewingController

    func preparePreviewOfFile(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            let html = try RendererRegistry.shared.render(url: url)
            // Use extension bundle as base so relative resource paths resolve correctly
            let baseURL = Bundle(for: PreviewViewController.self).resourceURL
            webView.loadHTMLString(html, baseURL: baseURL)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
}

// MARK: - WKNavigationDelegate

extension PreviewViewController: WKNavigationDelegate {
    /// Block all external navigation — this is a read-only preview.
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        switch navigationAction.navigationType {
        case .other:
            decisionHandler(.allow)
        default:
            decisionHandler(.cancel)
        }
    }
}
