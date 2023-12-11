// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ComeOnBoardOnboardingViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/12/23.
//

import UIKit
import Combine

final class ComeOnBoardOnboardingViewController: UIViewController {

    @IBOutlet private var titleLabel: UILabel? {
        didSet {
            titleLabel?.text = .localized("come_on_board_onboarding_title")
        }
    }

    @IBOutlet private var bodyLabel: UILabel? {
        didSet {
            bodyLabel?.text = .localized("come_on_board_onboarding_body")
        }
    }

    @IBOutlet private var headerStackView: UIStackView! {
        didSet {
            var contentConfiguration = VersionContentConfiguration()
            if
                let infoDictionary = Bundle.main.infoDictionary,
                let version = infoDictionary["CFBundleShortVersionString"] as? String,
                let buildNumber = infoDictionary["CFBundleVersion"] as? String {
                contentConfiguration.version = "\(version) (\(buildNumber))"
            }
            let versionView = VersionContentView(configuration: contentConfiguration)
            headerStackView.addArrangedSubview(versionView)
        }
    }

    @IBOutlet private var primaryButton: UIButton! {
        didSet {
            primaryButton
                .withTitle(.localized("understood_button_title"))
                .withDynamicType()
                .withFont(.NOI.dynamic.bodySemibold)
                .withTextAligment(.center)
        }
    }

    @IBOutlet private var secondaryButton: UIButton! {
        didSet {
            secondaryButton
                .withTitle(.localized("dont_show_again_toogle_title"))
                .withDynamicType()
                .withFont(.NOI.dynamic.bodySemibold)

            secondaryButton.setImage(
                #imageLiteral(resourceName: "checkbox_unchecked.pdf"),
                for: .normal
            )
            secondaryButton.setImage(
                #imageLiteral(resourceName: "checkbox_checked.pdf"),
                for: .selected
            )
        }
    }

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var footerContainerView: UIView!

    private var subscriptions: Set<AnyCancellable> = []
    private var viewModel: ComeOnBoardOnboardingViewModel!
    private var wasNavigationBarHidden = false

    init(viewModel: ComeOnBoardOnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(ComeOnBoardOnboardingViewController.self)", bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        title = .localized("come_on_board_onboarding_page_title")
        let insets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: footerContainerView.frame.height,
            right: 0
        )
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let navigationController
        else { return }

        wasNavigationBarHidden = navigationController.navigationBar.isHidden
        let queued = transitionCoordinator?.animateAlongsideTransition(in: navigationController.navigationBar,
                                                                       animation: { _ in
            navigationController.navigationBar.isHidden = false
        }) ?? false
        if !queued {
            navigationController.navigationBar.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let navigationController,
              wasNavigationBarHidden
        else { return }

        let queued = transitionCoordinator?.animateAlongsideTransition(in: navigationController.navigationBar,
                                                                       animation: { _ in
            navigationController.navigationBar.isHidden = true
        }) ?? false
        if !queued {
            navigationController.navigationBar.isHidden = true
        }
    }
}

// MARK: Private APIs

private extension ComeOnBoardOnboardingViewController {

    func configureBindings() {
        viewModel.$isDontShowThisAgainToggleOn
            .sink { [weak self] isOn in
                self?.secondaryButton.isSelected = isOn
            }
            .store(in: &subscriptions)

        primaryButton.publisher(for: .primaryActionTriggered)
            .sink { [weak self] in
                self?.viewModel.navigateToMainApp()
            }
            .store(in: &subscriptions)

        secondaryButton.publisher(for: .primaryActionTriggered)
            .sink { [weak self] in
                self?.viewModel.toggleDontShowThisAgainToggleOn()
            }
            .store(in: &subscriptions)
    }
}
