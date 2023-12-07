// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  AuthWelcomeViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import UIKit
import Combine

// MARK: - AuthWelcomeViewController

final class AuthWelcomeViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var viewModel: WelcomeViewModel
    
    private var pageToPageViewController: [Int: AuthWelcomePageViewController] = [:]
    
    @IBOutlet var pagesContainerView: UIView!

    @IBOutlet var footerView: UIView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton
                .withTitle(.localized("btn_login"))
                .withDynamicType()
                .withFont(.NOI.dynamic.bodySemibold)
                .withTextAligment(.center)
        }
    }
    
    @IBOutlet var signUpButton: UIButton! {
        didSet {
            signUpButton
                .withTitle(.localized("btn_signup"))
                .withDynamicType()
                .withFont(.NOI.dynamic.bodySemibold)
                .withTextAligment(.center)
        }
    }

    @IBOutlet var privacyTextView: UITextView! {
        didSet {
            privacyTextView.isSelectable = true
            privacyTextView.isEditable = false
            privacyTextView.isScrollEnabled = false
            privacyTextView.textContainer.lineFragmentPadding = 0
            privacyTextView.textContainerInset = .zero

            privacyTextView.delegate = self

            privacyTextView.linkTextAttributes = [
                .foregroundColor: UIColor.noiPrimaryColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]

            let text = String.localized("app_privacy_policy_label")
            let mAttributedText = NSMutableAttributedString(string: text,
                                                            attributes: [
                                                                .font: UIFont.preferredFont(forTextStyle: .body),
                                                                .foregroundColor: UIColor.noiPrimaryColor
                                                            ])

            if let range = text.range(of: String.localized("app_privacy_policy_label_link_part")),
               let url = URL(string: .localized("url_app_privacy")) {
                mAttributedText.addAttribute(.link,
                                             value: url,
                                             range: NSRange(range, in: text))
            }

            privacyTextView.attributedText = NSAttributedString(attributedString: mAttributedText)
        }
    }

    @IBOutlet var privacyButton: UIButton! {
        didSet {
            privacyButton.setImage(#imageLiteral(resourceName: "checkbox_unchecked.pdf"), for: .normal)
            privacyButton.setImage(#imageLiteral(resourceName: "checkbox_checked.pdf"), for: .selected)
        }
    }

    @IBOutlet var privacyContainerView: UIView! {
        didSet {
            privacyContainerView.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(togglePrivacy)
    )
    
    private lazy var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(AuthWelcomeViewController.self)", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBindings()
        
        pageControl.numberOfPages = viewModel.pages.count
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        embedChild(pageViewController, in: pagesContainerView)
        
        let firstPageVC = makePageContentViewController(for: 0)
        pageToPageViewController[0] = firstPageVC
        pageViewController.setViewControllers(
            [firstPageVC],
            direction: .forward,
            animated: false
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageToPageViewController.forEach { (_, pageVC) in
            pageVC.topMargin = view.convert(
                self.footerView.frame.origin,
                to: pageVC.view
            ).y - 18
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange(traitCollection.preferredContentSizeCategory)
        }
    }

    private func preferredContentSizeCategoryDidChange(_ previousPreferredContentSizeCategory: UIContentSizeCategory?) {
        guard let attributedText = privacyTextView.attributedText
        else { return }

        let text = attributedText.string
        let mAttributedText = NSMutableAttributedString(attributedString: attributedText)
        attributedText.enumerateAttribute(.font,
                                          in: NSRange(text.startIndex..., in: attributedText.string)) { value, range, stop in
            mAttributedText.addAttribute(.font,
                                         value: UIFont.preferredFont(forTextStyle: .body),
                                         range: range)
        }
        privacyTextView.attributedText = NSAttributedString(attributedString: mAttributedText)
    }
    
}

// MARK: Private APIs

private extension AuthWelcomeViewController {

    @objc private func togglePrivacy() {
        privacyButton.isSelected.toggle()
        viewModel.isPrivacyToggleOn = privacyButton.isSelected
    }
    
    func configureBindings() {
        viewModel.$isPrivacyToggleOn
            .sink { [weak self] isOn in
                self?.privacyButton.isSelected = isOn
            }
            .store(in: &subscriptions)

        viewModel.$isLoginButtonEnabled
            .sink { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
            }
            .store(in: &subscriptions)

        viewModel.$isSignUpButtonEnabled
            .sink { [weak self] isEnabled in
                self?.signUpButton.isEnabled = isEnabled
            }
            .store(in: &subscriptions)

        privacyButton.publisher(for: .primaryActionTriggered)
            .sink { [weak self] in
                self?.togglePrivacy()
            }
            .store(in: &subscriptions)

        loginButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.startLogin()
            }
            .store(in: &subscriptions)
        
        signUpButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel] in
                viewModel?.startSignUp()
            }
            .store(in: &subscriptions)
    }
    
    func knownPagePosition(of viewController: UIViewController) -> Int? {
        pageToPageViewController.first { $0.value === viewController }?.key
    }
    
    func pageContentViewController(
        from referenceViewController: UIViewController,
        requiringPageIndex: (Int) -> Int
    ) -> UIViewController? {
        let pageIndex = knownPagePosition(of: referenceViewController)!
        let requiredPageIndex = requiringPageIndex(pageIndex)
        
        guard viewModel.pages.indices.contains(requiredPageIndex)
        else { return nil }
        
        let pageVC: AuthWelcomePageViewController
        
        if let availablePageVC = pageToPageViewController[requiredPageIndex] {
            pageVC = availablePageVC
        } else {
            pageVC = makePageContentViewController(for: requiredPageIndex)
            pageToPageViewController[requiredPageIndex] = pageVC
        }
        
        return pageVC
    }
    
    func makePageContentViewController(
        for page: Int
    ) -> AuthWelcomePageViewController {
        let pageVC = AuthWelcomePageViewController(
            nibName: "\(AuthWelcomePageViewController.self)",
            bundle: nil
        )
        pageVC.configure(with: viewModel.pages[page])
        pageVC.topMargin = view.convert(
            self.footerView.frame.origin,
            to: pageVC.view
        ).y - 18
        return pageVC
    }
    
}

// MARK: UIPageViewControllerDataSource

extension AuthWelcomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        pageContentViewController(from: viewController) { $0 - 1 }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        pageContentViewController(from: viewController) { $0 + 1 }
    }
    
}

// MARK: UIPageViewControllerDelegate

extension AuthWelcomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            let pageContentVC = pageViewController.viewControllers?.first
            let currentPage = knownPagePosition(of: pageContentVC!)!
            pageControl.currentPage = currentPage
        }
    
}

// MARK: AuthWelcomePageViewController+Configuration

private extension AuthWelcomePageViewController {
    
    func configure(with page: WelcomePage) {
        loadViewIfNeeded()
        backgroundImageView.image = UIImage(named: page.backgroundImageName)
        textLabel.text = page.title
        detailedTextLabel.text = page.description
    }
    
}

extension AuthWelcomeViewController: UITextViewDelegate {

    public func textView(_ textView: UITextView,
                         shouldInteractWith url: URL,
                         in nsCharacterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        if url == URL(string: .localized("url_app_privacy")) {
            viewModel.navigateToAppPrivacy()
            return false
        }

        return true
    }
}
