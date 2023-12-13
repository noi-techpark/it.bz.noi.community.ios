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
        configureBindings()
        viewModel.fetchUserInfo()
    }
    
}

// MARK: Private APIs

private extension AccessNotGrantedViewController {
    
    func configureBindings() {
        viewModel.$userInfoIsLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoader()
                } else {
                    self?.showAccessNotGranted(userInfo: self?.viewModel.userInfoResult)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$userInfoResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                self?.showAccessNotGranted(userInfo: userInfo)
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

    private func showLoader() {
        navigationController?.navigationBar.isHidden = true

        content = LoadingViewController(style: .light)
    }

    private func showAccessNotGranted(userInfo userInfoOrNil: UserInfo?) {
        navigationController?.navigationBar.isHidden = false

        content = {
            let contentVC = BlockAccessViewController(nibName: nil, bundle: nil)
            contentVC.text = .localized("outsider_user_title")
            contentVC.detailedText = .localized("outsider_user_body")
            contentVC.primaryActionTitle = .localized("btn_logout")
            contentVC.primaryAction = { [weak self] in
                self?.viewModel.logout()
            }
            return contentVC
        }()
    }
}
