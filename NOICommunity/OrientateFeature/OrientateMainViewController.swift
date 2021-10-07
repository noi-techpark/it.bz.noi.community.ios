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
        configureChilds()
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
