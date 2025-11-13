// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ReauthenticatePopUpViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/12/23.
//

import UIKit
import Combine
import AuthClient

final class ReauthenticatePopUpViewController: UIViewController {

	private var wasNavigationBarHidden = false
	private let viewModel: ReauthenticatePopUpViewModel

	private var text: String? {
		didSet {
			titleLabel?.text = text
		}
	}

	private var detailedText: String? {
		didSet {
			bodyTextView?.text = detailedText
		}
	}

	private var detailedAttributedText: NSAttributedString? {
		didSet {
			bodyTextView?.attributedText = detailedAttributedText
		}
	}

	private var primaryActionTitle: String? {
		didSet {
			primaryButton?.setTitle(primaryActionTitle, for: .normal)
			primaryButton?.isHidden = primaryActionTitle == nil
		}
	}

	private var primaryAction: (() -> Void)? {
		didSet {
			primaryActionCancellable = primaryButton?.publisher(for: .primaryActionTriggered)
				.sink { [weak self] in
					self?.primaryAction?()
				}
		}
	}

	init(viewModel: ReauthenticatePopUpViewModel) {
		self.viewModel = viewModel
		super.init(nibName: "\(ReauthenticatePopUpViewController.self)", bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("\(#function) not available")
	}

	@IBOutlet private var titleLabel: UILabel? {
		didSet {
			titleLabel?.font = .NOI.dynamic.title3Semibold
			titleLabel?.text = text
		}
	}

	@IBOutlet private var bodyTextView: LinkTextView? {
		didSet {
			bodyTextView?.font = .NOI.dynamic.bodyRegular
			bodyTextView?.textAlignment = .center
			bodyTextView?.isSelectable = true
			bodyTextView?.isEditable = false
			bodyTextView?.isScrollEnabled = false
			bodyTextView?.textContainer.lineFragmentPadding = 0
			bodyTextView?.textContainerInset = .zero

			bodyTextView?.textColor = .noiSecondaryColor
			bodyTextView?.linkTextAttributes = [
				.foregroundColor: UIColor.noiSecondaryColor,
				.underlineStyle: NSUnderlineStyle.single.rawValue
			]

			switch (detailedText, detailedAttributedText) {
			case (_, let detailedAttributedText?):
				bodyTextView?.attributedText = detailedAttributedText
			case (let detailedText?, nil):
				bodyTextView?.text = detailedText
			case (nil, nil):
				bodyTextView?.text = nil
			}
		}
	}

	@IBOutlet private var headerStackView: UIStackView!

	@IBOutlet private var primaryButton: UIButton? {
		didSet {
			primaryButton?
				.withTitle(primaryActionTitle)
				.withDynamicType()
				.withFont(.NOI.dynamic.bodySemibold)
				.withTextAligment(.center)
			primaryButton?.isHidden = primaryActionTitle == nil
			primaryActionCancellable = primaryButton?.publisher(for: .primaryActionTriggered)
				.sink { [weak self] in
					self?.primaryAction?()
				}
		}
	}

	@IBOutlet private var scrollView: UIScrollView!

	@IBOutlet private var footerContainerView: UIView!

	private var primaryActionCancellable: AnyCancellable?

	override func viewDidLoad() {
		super.viewDidLoad()

		title = .localized("login_update_page_title")
		text = .localized("login_update_title")
		detailedText = .localized("login_update_body")
		primaryActionTitle = .localized("login_update_btn")
		primaryAction = { [weak self] in
			self?.viewModel.next()
		}
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

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let insets = UIEdgeInsets(
			top: 0,
			left: 0,
			bottom: footerContainerView.frame.height,
			right: 0
		)
		scrollView.contentInset = insets
		scrollView.scrollIndicatorInsets = insets
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
			preferredContentSizeCategoryDidChange(traitCollection.preferredContentSizeCategory)
		}
	}

}

// MARK: Private APIs

private extension ReauthenticatePopUpViewController {

	func preferredContentSizeCategoryDidChange(_ previousPreferredContentSizeCategory: UIContentSizeCategory?) {
		guard let attributedText = bodyTextView?.attributedText
		else { return }

		let text = attributedText.string
		let mAttributedText = NSMutableAttributedString(attributedString: attributedText)
		attributedText.enumerateAttribute(.font,
										  in: NSRange(text.startIndex..., in: attributedText.string)) { value, range, stop in
			mAttributedText.addAttribute(.font,
										 value: UIFont.preferredFont(forTextStyle: .body),
										 range: range)
		}
		bodyTextView?.attributedText = NSAttributedString(attributedString: mAttributedText)
	}

}
