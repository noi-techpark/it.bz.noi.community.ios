//
//  MoreCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/09/21.
//

import Foundation
import UIKit

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
        let myAccountVC = dependencyContainer.makeMyAccountViewController(
            viewModel: myAccountViewModel
        )
        myAccountVC.navigationItem.title = MoreViewModel.Entry.myAccount.localizedTitle
        myAccountVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(myAccountVC, animated: animated)
    }
    
}
