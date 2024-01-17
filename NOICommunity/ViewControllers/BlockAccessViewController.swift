// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BlockAccessViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 07/12/23.
//

import UIKit
import Combine
import AuthClient

final class BlockAccessViewController: UIViewController {

    var text: String? {
        didSet {
            titleLabel?.text = text
        }
    }

    var detailedText: String? {
        didSet {
            bodyTextView?.text = detailedText
        }
    }

    var detailedAttributedText: NSAttributedString? {
        didSet {
            bodyTextView?.attributedText = detailedAttributedText
        }
    }

    var primaryActionTitle: String? {
        didSet {
            primaryButton?.setTitle(primaryActionTitle, for: .normal)
            primaryButton?.isHidden = primaryActionTitle == nil
        }
    }

    var primaryAction: (() -> Void)? {
        didSet {
            primaryActionCancellable = primaryButton?.publisher(for: .primaryActionTriggered)
                .sink { [weak self] in
                    self?.primaryAction?()
                }
        }
    }

    var didTapJobsLinkAction: (() -> Void)?

    @IBOutlet private var titleLabel: UILabel? {
        didSet {
            titleLabel?.text = text
        }
    }

    @IBOutlet private var bodyTextView: LinkTextView? {
        didSet {
            bodyTextView?.isSelectable = true
            bodyTextView?.isEditable = false
            bodyTextView?.isScrollEnabled = false
            bodyTextView?.textContainer.lineFragmentPadding = 0
            bodyTextView?.textContainerInset = .zero

            bodyTextView?.delegate = self

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

private extension BlockAccessViewController {

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

// MARK: UITextViewDelegate

extension BlockAccessViewController: UITextViewDelegate {

    public func textView(_ textView: UITextView,
                         shouldInteractWith url: URL,
                         in nsCharacterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        if url == URL(string: .localized("url_jobs_noi_techpark")),
        let didTapJobsLinkAction {
            didTapJobsLinkAction()
            return false
        }

        return true
    }
}
