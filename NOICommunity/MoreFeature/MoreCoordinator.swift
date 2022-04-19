//
//  MoreCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import Foundation

final class MoreCoordinator: BaseNavigationCoordinator {

    var mainVC: MoreMainViewController!

    override func start(animated: Bool) {
        mainVC = MoreMainViewController()
        mainVC.didSelectHandler = { [weak navigationController] entry in
            let detailsVC = WebViewController()
            detailsVC.url = entry.url
            detailsVC.navigationItem.title = entry.localizedTitle
            detailsVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailsVC, animated: true)
        }
        mainVC.navigationItem.title = .localized("title_more")
        navigationController.viewControllers = [mainVC]
    }
}
