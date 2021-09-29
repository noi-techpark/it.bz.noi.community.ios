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

    @IBOutlet private var contentContainer: UIView!

    @IBOutlet private var actionsContainersView: UIView! {
        didSet {
            actionsContainersView.layer.shadowPath = UIBezierPath(rect: actionsContainersView.bounds).cgPath
            actionsContainersView.layer.shadowColor = UIColor.backgroundColor.cgColor
            actionsContainersView.layer.shadowRadius = 5
            actionsContainersView.layer.shadowOffset = .zero
            actionsContainersView.layer.shadowOpacity = 0.16
        }
    }

    @IBOutlet private var bookRoomButton: UIButton! {
        didSet {
            bookRoomButton.setTitle(
                .localized("room_booking"),
                for: .normal
            )
        }
    }

    init() {
        super.init(nibName: "\(Self.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureChilds()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionsContainersView.layer.shadowPath = UIBezierPath(rect: actionsContainersView.bounds).cgPath
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: Private APIs

private extension OrientateMainViewController {
    func configureChilds() {
        webVC = WebViewController()
        webVC.url = .map
        webVC.navigationItem.title = .localized("title_orientate")
        embedChild(webVC, in: contentContainer)
    }

    @IBAction func bookRoomAction(sender: Any?) {
        bookRoomActionHandler?()
    }
}
