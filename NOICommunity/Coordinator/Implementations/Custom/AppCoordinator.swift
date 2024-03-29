// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AppCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/04/22.
//

import Foundation
import Combine
import SafariServices
import MessageUI
import ArticlesClient
import AuthStateStorageClient
import AuthClient

let logoutNotification = Notification.Name("logout")

// MARK: - AppCoordinator

final class AppCoordinator: BaseNavigationCoordinator {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var isAutorizedClient = dependencyContainer
        .makeIsAutorizedClient()

    private var pendingDeepLinkIntent: DeepLinkIntent?
    
    private weak var tabCoordinator: TabCoordinator!
    
    override func start(animated: Bool) {
        NotificationCenter
            .default
            .publisher(for: logoutNotification)
            .sink { [weak self] _ in
                self?.logout(animated: true)
            }
            .store(in: &subscriptions)
        
        if !isAutorizedClient() {
            showAuthCoordinator()
        } else {
            showLoadUserInfo()
        }
    }
    
    func handle(deepLinkIntent: DeepLinkIntent) {
        // Handle deep linking only when the app tabs are visible
        guard tabCoordinator != nil
        else {
            pendingDeepLinkIntent = deepLinkIntent
            return
        }
        
        switch deepLinkIntent {
        case .showNews(let newsId):
            showNewsDetails(newsId: newsId, sender: deepLinkIntent)
        }
    }
    
}

// MARK: Private APIs

private extension AppCoordinator {
    
    func showAuthCoordinator(animated: Bool = false) {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        authCoordinator.didFinishHandler = { [weak self] in
            self?.authCoordinatorDidFinish($0)
        }
        childCoordinators.append(authCoordinator)
        authCoordinator.start(animated: animated)

        navigationController.navigationBar.isHidden = true
    }
    
    func showLoadUserInfo(animated: Bool = false) {
        let loadUserInfoCoordinator = LoadUserInfoCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        loadUserInfoCoordinator.didFinishHandler = { [weak self] in
            self?.loadUserInfoCoordinatorDidFinish($0, with: $1)
        }
        childCoordinators.append(loadUserInfoCoordinator)
        loadUserInfoCoordinator.start(animated: animated)
    }

    func showTabCoordinator(animated: Bool = false) {
        let tabBarController = TabBarController()
        let tabCoordinator = TabCoordinator(
            tabBarController: tabBarController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(tabCoordinator)
        self.tabCoordinator = tabCoordinator
        tabCoordinator.start()
        navigationController.setViewControllers(
            [tabBarController],
            animated: animated
        )

        if let pendingDeepLinkIntent = self.pendingDeepLinkIntent {
            handle(deepLinkIntent: pendingDeepLinkIntent)
            self.pendingDeepLinkIntent = nil
        }
    }

    func showComeOnBoardOnboardingCoordinator(animated: Bool) {
        let comeOnBoardOnboardingCoordinator = ComeOnBoardOnboardingCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        comeOnBoardOnboardingCoordinator.didFinishHandler = { [weak self] coordinator in
            self?.sacrifice(child: coordinator)
            self?.showTabCoordinator(animated: true)
        }
        childCoordinators.append(comeOnBoardOnboardingCoordinator)
        comeOnBoardOnboardingCoordinator.start(animated: animated)
    }

    func showAuthorizedContent(animated: Bool) {
        let skipComeOnBoardOnboarding = {
            let appPreferencesClient = self.dependencyContainer
                .makeAppPreferencesClient()
            return appPreferencesClient
                .fetch()
                .skipComeOnBoardOnboarding
        }

        if !skipComeOnBoardOnboarding() {
            showComeOnBoardOnboardingCoordinator(animated: true)
        } else {
            showTabCoordinator(animated: true)
        }
    }
    
    
    func authCoordinatorDidFinish(
        _ authCoordinator: AuthCoordinator
    ) {
        sacrifice(child: authCoordinator)
        showLoadUserInfo()
    }
    
    func loadUserInfoCoordinatorDidFinish(
        _ loadUserInfoCoordinator: LoadUserInfoCoordinator,
        with result: Result<Void, Error>
    ) {
        sacrifice(child: loadUserInfoCoordinator)

        switch result {
        case .success:
            showAuthorizedContent(animated: true)
        case .failure(AuthError.OAuthTokenInvalidGrant):
            logout(animated: true)
        case .failure(LoadUserInfoError.outsider):
            showAccessNotGrantedCoordinator(animated: true)
        case .failure(_):
            showAuthorizedContent(animated: true)
        }
    }
    
    func logout(animated: Bool) {
        childCoordinators = []
        showAuthCoordinator(animated: animated)
    }
    
    func showNewsExternalLink(of news: Article, sender: Any?) {
        let author = localizedValue(from: news.languageToAuthor)
        let safariVC = SFSafariViewController(url: author!.externalURL!)
        navigationController.presentedViewController?.present(
            safariVC,
            animated: true
        )
    }
    
    func showNewsAskAQuestion(for news: Article, sender: Any?) {
        let author = localizedValue(from: news.languageToAuthor)
        navigationController.presentedViewController?.mailTo(
            author!.email!,
            delegate: self,
            completion: nil
        )
    }
    
    func showNewsDetails(newsId: String, sender: Any?) {
        func configureBindings(
            viewModel: NewsDetailsViewModel,
            detailsViewController: NewsDetailsViewController
        ) {
            viewModel.showExternalLinkPublisher
                .sink { [weak self] (news, sender) in
                    self?.showNewsExternalLink(of: news, sender: sender)
                }
                .store(in: &subscriptions)
            viewModel.showAskAQuestionPublisher
                .sink { [weak self] (news, sender) in
                    self?.showNewsAskAQuestion(for: news, sender: sender)
                }
                .store(in: &subscriptions)
            viewModel.$result
                .sink { [weak detailsViewController] news in
                    guard let news = news
                    else { return }
                    
                    detailsViewController?.navigationItem.title = localizedValue(
                        from: news.languageToDetails
                    )?
                        .title
                }
                .store(in: &subscriptions)
        }
        
        let viewModel = dependencyContainer.makeNewsDetailsViewModel(
            availableNews: nil
        )
        
        let detailsVC = dependencyContainer.makeNewsDetailsViewController(
            newsId: newsId,
            viewModel: viewModel
        )
        
        configureBindings(
            viewModel: viewModel,
            detailsViewController: detailsVC
        )
        
        detailsVC.navigationItem.title = nil
        detailsVC.navigationItem.largeTitleDisplayMode = .never
        detailsVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(closeModal(sender:))
        )
        detailsVC.modalPresentationStyle = .fullScreen
        
        navigationController.present(
            NavigationController(rootViewController: detailsVC),
            animated: true
        )
    }
    
    @objc func closeModal(sender: Any?) {
        navigationController.dismiss(animated: true)
    }

    func showAccessNotGrantedCoordinator(animated: Bool) {
        let accessNotGrantedCoordinator = AccessNotGrantedCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer
        )
        childCoordinators.append(accessNotGrantedCoordinator)
        accessNotGrantedCoordinator.start(animated: animated)
    }

}

// MARK: MFMailComposeViewControllerDelegate

extension AppCoordinator: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith _: MFMailComposeResult,
        error _: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
