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
    
    private lazy var myAccountViewModel = dependencyContainer
        .makeMyAccountViewModel()
    
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
        myAccountViewModel
            .$userInfoResult
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self
                else { return }
                
                self.didFinishHandler(self, .success(()))
            }
            .store(in: &subscriptions)
        
        myAccountViewModel
            .$error
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self
                else { return }
                
                guard let error = error
                else { return }
                
                self.didFinishHandler(self, .failure(error))
            }
            .store(in: &subscriptions)
        
        myAccountViewModel.fetchUserInfo()
    }
    
}
