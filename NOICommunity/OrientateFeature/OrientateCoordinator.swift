// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  OrientateCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

final class OrientateCoordinator: BaseNavigationCoordinator {

    var mainVC: OrientateMainViewController!

    override func start(animated: Bool) {
        mainVC = OrientateMainViewController()
        mainVC.bookRoomActionHandler = { [weak navigationController] in
            let bookRoomVC = WebViewController()
            bookRoomVC.url = .roomBooking
            bookRoomVC.navigationItem.title = .localized("room_booking")
            bookRoomVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(bookRoomVC, animated: true)
        }
        mainVC.navigationItem.title = .localized("title_orientate")
        navigationController.viewControllers = [mainVC]
    }
}
