// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  WebViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/21.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    lazy var webView: WKWebView = { webView in
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .noiSecondaryBackgroundColor
        return webView
    }(WKWebView())
    
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = { activityIndicator in
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.sizeToFit()
        activityIndicator.color = .noiPrimaryColor
        return activityIndicator
    }(UIActivityIndicatorView())
    
    private var wasNavigationBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = webView.backgroundColor
        configureViewHierarchy()
        updateUI(for: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navigationController
        else { return }
        
        wasNavigationBarHidden = navigationController.navigationBar.isHidden
        let queued = transitionCoordinator?.animateAlongsideTransition(in: navigationController.navigationBar,
                                                                       animation: { _ in
            navigationController.navigationBar.isHidden = false
        }) ?? false
        if !queued {
            navigationController.navigationBar.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let navigationController,
              wasNavigationBarHidden
        else { return }
        
        let queued = transitionCoordinator?.animateAlongsideTransition(in: navigationController.navigationBar,
                                                                       animation: { _ in
            navigationController.navigationBar.isHidden = true
        }) ?? false
        if !queued {
            navigationController.navigationBar.isHidden = true
        }
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
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            webView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            webView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            webView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            )
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: activityIndicator
        )
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
