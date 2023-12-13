// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ComeOnBoardOnboardingCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/12/23.
//

import Foundation
import Combine

// MARK: - ComeOnBoardOnboardingCoordinator

final class ComeOnBoardOnboardingCoordinator: BaseNavigationCoordinator {

    var didFinishHandler: ((ComeOnBoardOnboardingCoordinator) -> Void)!

    private var subscriptions: Set<AnyCancellable> = []
    
    override func start(animated: Bool) {
        showComeOnBoardOnboarding(animated: animated)
    }

}

// MARK: Private APIs

private extension ComeOnBoardOnboardingCoordinator {

    func showComeOnBoardOnboarding(animated: Bool) {
        let viewModel = dependencyContainer.makeComeOnBoardOnboardingViewModel()
        viewModel.navigateToMainAppPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self
                else { return }

                self.didFinishHandler(self)
            }
            .store(in: &subscriptions)
        let viewController = dependencyContainer
            .makeComeOnBoardOnboardingViewController(viewModel: viewModel)
        navigationController.setViewControllers(
            [viewController],
            animated: animated
        )
    }

}
