import Cocoa
import Quartz
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!
    private var pendingCompletion: ((Error?) -> Void)?

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = false

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        view.addSubview(webView)
    }

    // MARK: - QLPreviewingController

    func preparePreviewOfFile(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        // Store completion — we call it after WKWebView finishes loading
        pendingCompletion = completionHandler

        // Force viewDidLoad by accessing view
        _ = view

        let html: String
        do {
            html = try RendererRegistry.shared.render(url: url)
        } catch {
            html = HTMLTemplate.wrap(
                title: url.lastPathComponent,
                body: "<p style='color:red;padding:24px'>Could not read file: \(HTMLTemplate.escapeHTML(error.localizedDescription))</p>"
            )
        }

        webView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - WKNavigationDelegate

extension PreviewViewController: WKNavigationDelegate {

    // Signal ready only after HTML is fully rendered
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pendingCompletion?(nil)
        pendingCompletion = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        pendingCompletion?(error)
        pendingCompletion = nil
    }

    // Block all external navigation — read-only preview
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(navigationAction.navigationType == .other ? .allow : .cancel)
    }
}
