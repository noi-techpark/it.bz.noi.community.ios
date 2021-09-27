//
//  MeetCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

final class MeetCoordinator: BaseCoordinator {

    var mainVC: MeetMainViewController!

    override func start(animated: Bool) {
        mainVC = MeetMainViewController()
        mainVC.didSelectHandler = { [weak navigationController] entry in
            let detailVC = WebViewController()
            detailVC.url = entry.url
            detailVC.navigationItem.title = entry.localizedTitle
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        }
        mainVC.navigationItem.title = .localized("title_meet")
        navigationController.viewControllers = [mainVC]
    }
}
