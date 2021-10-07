//
//  WebViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!

    var url: URL? {
        didSet {
            guard url != oldValue
            else { return }

            if isViewLoaded {
                updateUI(for: url)
            }
        }
    }

    var isLoadingHandler: ((Bool) -> Void)?

    private var activityIndicator: UIActivityIndicatorView!

    override func loadView() {
        webView = { webView in
            webView.navigationDelegate = self
            webView.allowsBackForwardNavigationGestures = true
            return webView
        }(WKWebView())
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondaryBackgroundColor
        configureViewHierarchy()
        updateUI(for: url)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setIsLoading(false)
    }

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        setIsLoading(true)
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        setIsLoading(false)
    }
}

// MARK: Private APIs

private extension WebViewController {
    func configureViewHierarchy() {
        activityIndicator = { activityIndicator in
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = .medium
            return activityIndicator
        }(UIActivityIndicatorView())

        activityIndicator.sizeToFit()
        activityIndicator.color = .primaryColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }

    func updateUI(for url: URL?) {
        if let url = url {
            webView.load(URLRequest(url: url))
        } else {
            webView.load(URLRequest(url: URL(string:"about:blank")!))
        }
    }

    func setIsLoading(_ isLoading: Bool) {
        isLoadingHandler?(isLoading)
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}
