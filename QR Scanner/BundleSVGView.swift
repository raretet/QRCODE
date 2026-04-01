import SwiftUI
import WebKit

struct BundleSVGView: UIViewRepresentable {
    let resourceName: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isUserInteractionEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedName != resourceName else { return }
        context.coordinator.loadedName = resourceName
        let url = Bundle.main.url(forResource: resourceName, withExtension: "svg", subdirectory: "Resources")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "svg")
        guard let fileURL = url, let svg = try? String(contentsOf: fileURL, encoding: .utf8) else { return }
        let html = """
        <!DOCTYPE html>
        <html><head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <style>
        html,body{margin:0;padding:0;width:100%;height:100%;background:transparent;overflow:hidden;}
        .wrap{width:100%;height:100%;display:flex;align-items:center;justify-content:center;}
        svg{max-width:100%;max-height:100%;width:auto;height:auto;}
        </style></head><body><div class="wrap">\(svg)</div></body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    final class Coordinator {
        var loadedName: String?
    }
}
