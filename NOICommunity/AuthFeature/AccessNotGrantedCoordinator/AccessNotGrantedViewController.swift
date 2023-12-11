// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AccessNotGrantedViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 02/05/22.
//

import UIKit
import Combine
import AuthClient

// MARK: - AccessNotGrantedViewController

final class AccessNotGrantedViewController: ContainerViewController {
    
    let viewModel: MyAccountViewModel
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(viewModel: MyAccountViewModel) {
        self.viewModel = viewModel
        
        super.init(content: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    @available(*, unavailable)
    override init(content: UIViewController?) {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = .localized("warning_title")
        navigationController?.navigationBar.prefersLargeTitles = true
        configureBindings()
        viewModel.fetchUserInfo()
    }
    
}

// MARK: Private APIs

private extension AccessNotGrantedViewController {
    
    func makeAvailableContent(
        userInfo userInfoOrNil: UserInfo?
    ) -> UIViewController {
        let detailedText: String
        
        if let userInfo = userInfoOrNil {
            detailedText = .localizedStringWithFormat(
                .localized("access_not_granted_format"),
                userInfo.name ?? "N/D",
                userInfo.email ?? "N/D"
            )
        } else {
            detailedText = .localized("access_not_granted_msg")
        }

        let contentVC = BlockAccessViewController(nibName: nil, bundle: nil)
        contentVC.text = .localized("label_access_not_granted")
        contentVC.detailedText = detailedText
        contentVC.primaryActionTitle = .localized("btn_logout")
        contentVC.primaryAction = { [weak self] in
            self?.viewModel.logout()
        }
        return contentVC
    }
    
    func configureBindings() {
        viewModel.$userInfoIsLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.content = LoadingViewController(style: .light)
                } else {
                    self?.navigationController?.navigationBar.isHidden = false
                    self?.content = self?.makeAvailableContent(
                        userInfo: self?.viewModel.userInfoResult
                    )
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfoResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                self?.content = self?.makeAvailableContent(userInfo: userInfo)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error
                else { return }
                
                switch error {
                case AuthError.userCanceledAuthorizationFlow:
                    break
                default:
                    self?.showError(error)
                }
            }
            .store(in: &subscriptions)
    }
    
}
