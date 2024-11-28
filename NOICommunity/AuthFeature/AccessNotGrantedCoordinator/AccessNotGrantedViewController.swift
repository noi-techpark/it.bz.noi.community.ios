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

    private lazy var loadingViewController = LoadingViewController(style: .light)

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
                }
            }
            .store(in: &subscriptions)

        viewModel.$userInfoResult
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userInfo in
                self?.showAccessNotGranted(with: userInfo)
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

        content = loadingViewController
    }

    private func showAccessNotGranted(with userInfo: UserInfo) {
        navigationController?.navigationBar.isHidden = false

        let accessNotGrantedViewController: BlockAccessViewController = {
            let contentVC = BlockAccessViewController(nibName: nil, bundle: nil)
            contentVC.text = .localized("outsider_user_title")
            let detailedAttributedText: NSAttributedString = {
                let text = String.localizedStringWithFormat(
                    .localized("outsider_user_body_format"),
                    userInfo.email ?? "N/D"
                )
                let mAttributedText = NSMutableAttributedString(string: text,
                                                                attributes: [
                                                                    .font: UIFont.preferredFont(forTextStyle: .body),
                                                                    .foregroundColor: UIColor.noiSecondaryColor
                                                                ])

                if let range = text.range(of: String.localized("outsider_user_body_link_1_part")),
                   let url = URL(string: .localized("url_jobs_noi_techpark")) {
                    mAttributedText.addAttribute(.link,
                                                 value: url,
                                                 range: NSRange(range, in: text))
                }

                return NSAttributedString(attributedString: mAttributedText)
            }()
            contentVC.detailedAttributedText = detailedAttributedText
            contentVC.primaryActionTitle = .localized("btn_logout")
            return contentVC
        }()
        accessNotGrantedViewController.primaryAction = { [weak self] in
            self?.viewModel.logout()
        }
        accessNotGrantedViewController.didTapJobsLinkAction = { [weak self] in
            self?.viewModel.navigateToNoiTechparkJobs()
        }
        content = accessNotGrantedViewController
    }
}
