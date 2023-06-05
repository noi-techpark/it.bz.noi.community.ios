// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MoreCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import UIKit
import MessageUI

final class MoreCoordinator: BaseNavigationCoordinator {

    private var mainVC: MoreMainViewController!
    

    override func start(animated: Bool) {
        mainVC = MoreMainViewController()
        mainVC.didSelectHandler = { [weak self] entry in
            switch entry {
            case .myAccount:
                self?.showMyAccount(animated: true)
            default:
                self?.showWebPage(of: entry, animated: true)
            }
        }
        mainVC.navigationItem.title = .localized("title_more")
        navigationController.viewControllers = [mainVC]
    }
}

// MARK: Private APIs

private extension MoreCoordinator {
    
    func showWebPage(of entry: MoreViewModel.Entry, animated: Bool) {
        let detailsVC = WebViewController()
        detailsVC.url = entry.url
        detailsVC.navigationItem.title = entry.localizedTitle
        detailsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailsVC, animated: animated)
    }
    
    func showMyAccount(animated: Bool) {
        let myAccountViewModel = dependencyContainer.makeMyAccountViewModel()
        myAccountViewModel.requestAccountDeletionHandler = { [weak self] in
            self?.composeDeleteAccountEmail()
        }
        let myAccountVC = dependencyContainer.makeMyAccountViewController(
            viewModel: myAccountViewModel
        )
        myAccountVC.navigationItem.title = MoreViewModel.Entry.myAccount.localizedTitle
        myAccountVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(myAccountVC, animated: animated)
    }
    
    func composeDeleteAccountEmail() {
        navigationController.mailTo(
            EmailParameters(
                toEmails: ["community@noi.bz.it"],
                subject: .localized("delete_profile_compose_subject"),
                body: .localized("delete_profile_compose_body")
            )!,
            delegate: self,
            completion: nil
        )
    }
    
}

// MARK: MFMailComposeViewControllerDelegate

extension MoreCoordinator: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith _: MFMailComposeResult,
        error _: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}

