// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ReauthenticatePopUpCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/11/25.
//

import Foundation
import Combine

// MARK: - ReauthenticatePopUpCoordinator

final class ReauthenticatePopUpCoordinator: BaseNavigationCoordinator {

    var didFinishHandler: ((ReauthenticatePopUpCoordinator) -> Void)!

    private var subscriptions: Set<AnyCancellable> = []
    
    override func start(animated: Bool) {
        showReauthenticatePopUp(animated: animated)
    }

}

// MARK: Private APIs

private extension ReauthenticatePopUpCoordinator {

    func showReauthenticatePopUp(animated: Bool) {
        let viewModel = dependencyContainer.makeReauthenticatePopUpViewModel()
        viewModel.nextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self
                else { return }

                self.didFinishHandler(self)
            }
            .store(in: &subscriptions)
        let viewController = dependencyContainer
            .makeReauthenticatePopUpViewController(viewModel: viewModel)		
        navigationController.setViewControllers(
            [viewController],
            animated: animated
        )
    }

}
