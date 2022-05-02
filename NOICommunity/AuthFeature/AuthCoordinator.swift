//
//  AuthCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 19/04/22.
//

import UIKit
import Foundation
import Combine
import SafariServices
import AuthClient

let kAppAuthExampleAuthStateKey: String = "authState";


// MARK: - AuthCoordinatorError

enum AuthCoordinatorError: Error, Hashable {
    case accessNotGranted
}

// MARK: - AuthCoordinator

final class AuthCoordinator: BaseNavigationCoordinator {
    
    var didFinishHandler: ((AuthCoordinator) -> Void)!
    
    private var mainVC: AuthWelcomeViewController!
    private var welcomeViewModel: WelcomeViewModel!
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var authClient = dependencyContainer.makeAuthClient()
    
    override func start(animated: Bool) {
        showWelcome(animated: animated)
    }
    
}

// MARK: Private APIs

private extension AuthCoordinator {
    
    func goToLogin() {
        authClient.accessToken()
            .sink { [weak self] completion in
                guard let self = self
                else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleAuthError(error)
                }
            } receiveValue: { [weak self] accessToken in
                guard let self = self
                else { return }
                
                self.didFinishHandler(self)
            }
            .store(in: &subscriptions)
    }
    
    func goToSignUp() {
        let safariVC = SFSafariViewController(url: AuthConstant.signupURL)
        navigationController.present(safariVC, animated: true)
    }
    
    func showWelcome(animated: Bool) {
        welcomeViewModel = dependencyContainer.makeWelcomeViewModel()
        welcomeViewModel.startLoginPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.goToLogin()
            }
            .store(in: &subscriptions)
        welcomeViewModel.startSignUpPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.goToSignUp()
            }
            .store(in: &subscriptions)
        
        mainVC = dependencyContainer
            .makeWelcomeViewController(viewModel: welcomeViewModel)
        navigationController.setViewControllers([mainVC], animated: animated)
    }
    
    func handleAuthError(_ error: Error) {
        switch error {
        case AuthError.userCanceledAuthorizationFlow:
            break
        default:
            navigationController.showError(error)
        }
    }
    
}
