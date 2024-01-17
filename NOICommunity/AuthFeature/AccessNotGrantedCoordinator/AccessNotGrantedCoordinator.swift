// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AccessNotGrantedCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 02/05/22.
//

import Foundation

// MARK: - RootCoordinator

final class AccessNotGrantedCoordinator: BaseNavigationCoordinator {
    
    override func start(animated: Bool) {
        showAccessNotGranted(animated: animated)
    }
    
}

// MARK: Private APIs

private extension AccessNotGrantedCoordinator {
    
    func showAccessNotGranted(animated: Bool) {
        let myAccountViewModel = dependencyContainer.makeMyAccountViewModel()
        myAccountViewModel.navigateToNoiTechparkJobsHandler = { [weak self] in
            self?.navigateToNoiTechparkJobsHandler()
        }
        let accessNotGrantedVC = dependencyContainer
            .makeAccessNotGrantedViewController(viewModel: myAccountViewModel)
        navigationController.setViewControllers(
            [accessNotGrantedVC],
            animated: animated
        )
    }

    func navigateToNoiTechparkJobsHandler() {
        guard let url = URL(string: .localized("url_jobs_noi_techpark"))
        else { return }

        let webVC = WebViewController()
        webVC.url = url.addQueryParams(fullview: true)
        webVC.navigationItem.title = .localized("noi_techpark_jobs_page_title")
        navigationController.pushViewController(webVC, animated: true)
    }

}
