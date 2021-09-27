//
//  WebViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var url: URL? {
        didSet {
            guard url != oldValue
            else { return }

            if isViewLoaded {
                updateUI(for: url)
            }
        }
    }
    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI(for: url)
    }
}

// MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

}

// MARK: Private APIs

private extension WebViewController {
    func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

    func updateUI(for url: URL?) {
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            webView.load(URLRequest(url: URL(string:"about:blank")!))
        }
    }
}
