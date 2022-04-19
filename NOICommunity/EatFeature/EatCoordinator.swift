//
//  EatCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/09/21.
//

import Foundation

final class EatCoordinator: BaseNavigationCoordinator {

    var mainVC: EatMainViewController!

    override func start(animated: Bool) {
        mainVC = EatMainViewController()
        mainVC.showMenuHandler = { [weak navigationController] entry in
            let detailVC = WebViewController()
            detailVC.url = entry.menuURL
            detailVC.navigationItem.title = entry.name
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        }
        mainVC.navigationItem.title = .localized("title_eat")
        navigationController.viewControllers = [mainVC]
    }
}
