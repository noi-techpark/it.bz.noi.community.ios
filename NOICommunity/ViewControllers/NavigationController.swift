//
//  NavigationController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/21.
//

import UIKit

class NavigationController: UINavigationController {

    private var defaultDelegate: UINavigationControllerDelegate!

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(
            navigationBarClass: navigationBarClass,
            toolbarClass: toolbarClass
        )
        configure()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configure()
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}

private extension NavigationController {
    func configure() {
        defaultDelegate = NavigationControllerDelegate()
        delegate = defaultDelegate
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // Removes any label from navigation back button
        viewController.navigationItem.backButtonDisplayMode = .minimal
    }
}
