// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  LoadUserInfoCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 02/05/22.
//

import Foundation
import Combine

// MARK: - LoadUserInfoCoordinator

final class LoadUserInfoCoordinator: BaseNavigationCoordinator {
    
    private lazy var viewModel = dependencyContainer
        .makeLoadUserInfoViewModel()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    var didFinishHandler: ((
        LoadUserInfoCoordinator,
        Result<Void, Error>
    ) -> Void)!
    
    override func start(animated: Bool) {
        showUserInfoLoading(animated: animated)
    }
    
}

// MARK: Private APIs

private extension LoadUserInfoCoordinator {
    
    func showUserInfoLoading(animated: Bool) {
        navigationController.setViewControllers(
            [LoadingViewController(style: .light)],
            animated: animated
        )

        viewModel.resultPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self
                    else { return }

                    switch completion {
                    case .finished:
                        self.didFinishHandler(self, .success(()))
                    case .failure(let error):
                        self.didFinishHandler(self, .failure(error))
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)
        
        viewModel.fetchVerifiedUserInfo()
    }
    
}
