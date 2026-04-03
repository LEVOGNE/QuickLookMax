import Cocoa
import Quartz
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!

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
        let html: String
        do {
            html = try RendererRegistry.shared.render(url: url)
        } catch {
            html = HTMLTemplate.wrap(
                title: url.lastPathComponent,
                body: "<p style='color:red;padding:24px'>Error loading file: \(HTMLTemplate.escapeHTML(error.localizedDescription))</p>"
            )
        }
        webView.loadHTMLString(html, baseURL: nil)
        completionHandler(nil)
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
