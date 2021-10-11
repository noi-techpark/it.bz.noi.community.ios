//
//  OrientateMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit

final class OrientateMainViewController: UIViewController {

    var bookRoomActionHandler: (() -> Void)?

    private var webVC: WebViewController!

    private var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private var contentContainer: UIView!

    @IBOutlet private var actionsContainersView: FooterView!

    @IBOutlet private var bookRoomButton: UIButton! {
        didSet {
            bookRoomButton.configureAsActionButton()
            bookRoomButton.setTitle(.localized("room_booking"), for: .normal)
        }
    }

    init() {
        super.init(nibName: "\(OrientateMainViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureChilds()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension OrientateMainViewController {

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

    func configureChilds() {
        webVC = MapWebViewController()
        webVC.url = .map
        webVC.isLoadingHandler = { [weak self] isLoading in
            self?.setIsLoading(isLoading)
        }
        webVC.navigationItem.title = .localized("title_orientate")
        embedChild(webVC, in: contentContainer)
    }

    func setIsLoading(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    @IBAction func bookRoomAction(sender: Any?) {
        bookRoomActionHandler?()
    }
}
