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
            bodyLabel?.text = detailedText
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

    var secondaryActionTitle: String? {
        didSet {
            secondaryButton?.setTitle(secondaryActionTitle, for: .normal)
            secondaryButton?.isHidden = secondaryActionTitle == nil
        }
    }

    var secondaryAction: (() -> Void)? {
        didSet {
            secondaryActionCancellable = secondaryButton?.publisher(for: .primaryActionTriggered)
                .sink { [weak self] in
                    self?.secondaryAction?()
                }
        }
    }

    var tertiaryActionTitle: String? {
        didSet {
            tertiaryButton?.setTitle(tertiaryActionTitle, for: .normal)
            tertiaryButton?.isHidden = tertiaryActionTitle == nil
        }
    }

    var tertiaryAction: (() -> Void)? {
        didSet {
            tertiaryActionCancellable = tertiaryButton?.publisher(for: .primaryActionTriggered)
                .sink { [weak self] in
                    self?.tertiaryAction?()
                }
        }
    }

    @IBOutlet private var titleLabel: UILabel? {
        didSet {
            titleLabel?.text = text
        }
    }

    @IBOutlet private var bodyLabel: UILabel? {
        didSet {
            bodyLabel?.text = detailedText
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

    @IBOutlet private var secondaryButton: UIButton? {
        didSet {
            secondaryButton?
                .withTitle(secondaryActionTitle)
                .withDynamicType()
                .withFont(.NOI.dynamic.bodySemibold)
                .withTextAligment(.center)
            secondaryButton?.isHidden = secondaryActionTitle == nil
            secondaryActionCancellable = secondaryButton?.publisher(for: .primaryActionTriggered)
                .sink { [weak self] in
                    self?.secondaryAction?()
                }
        }
    }

    @IBOutlet private var tertiaryButton: UIButton? {
        didSet {
            tertiaryButton?.setTitle(tertiaryActionTitle, for: .normal)
            tertiaryButton?.isHidden = tertiaryActionTitle == nil
            tertiaryActionCancellable = tertiaryButton?.publisher(for: .primaryActionTriggered)
                .sink { [weak self] in
                    self?.tertiaryAction?()
                }
        }
    }

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var footerContainerView: UIView!

    private var primaryActionCancellable: AnyCancellable?
    private var secondaryActionCancellable: AnyCancellable?
    private var tertiaryActionCancellable: AnyCancellable?

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

}
