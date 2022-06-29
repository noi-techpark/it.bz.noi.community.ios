//
//  VersionContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 04/10/21.
//

import UIKit

// MARK: - VersionContentView

class VersionContentView: UIView, UIContentView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var logoImageView: UIImageView!
    
    @IBOutlet var logoImageViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            updateLogoDynamicTypeHeight()
        }
    }

    @IBOutlet var textLabel: UILabel! {
        didSet {
            textLabel.font = .NOI.caption1Regular
        }
    }

    private var currentConfiguration: VersionContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? VersionContentConfiguration
            else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    init(configuration: VersionContentConfiguration) {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            updateLogoDynamicTypeHeight()
        }
    }
}

// MARK: Private APIs

private extension VersionContentView {
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(VersionContentView.self)",
            owner: self,
            options: nil
        )
        embedSubview(containerView)
        
        let crashTapGesture = UITapGestureRecognizer()
        crashTapGesture.numberOfTouchesRequired = 3
        crashTapGesture.numberOfTapsRequired = 2
        crashTapGesture.addTarget(
            self,
            action: #selector(didRecognizeCrashTapGesture)
        )
        addGestureRecognizer(crashTapGesture)
    }
    
    func apply(configuration: VersionContentConfiguration) {
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Update text label
        textLabel.setText(
            (configuration.attributedVersion, configuration.version),
            textProperties: configuration.textProprieties
        )
    }
    
    func updateLogoDynamicTypeHeight() {
        logoImageViewHeightConstraint?.constant = UIFontMetrics(
            forTextStyle: .largeTitle
        ).scaledValue(for: 44)
    }
    
    @objc func didRecognizeCrashTapGesture() {
        let numbers = [0]
        _ = numbers[1]
    }
}

// MARK: - VersionContentConfiguration

struct VersionContentConfiguration: UIContentConfiguration {
    
    /// The version text.
    var version: String?
    
    /// An attributed variant of the version text.
    var attributedVersion: NSAttributedString?
    
    /// Properties for configuring the primary text.
    var textProprieties = ContentConfiguration.TextProperties()
    
    func makeContentView() -> UIView & UIContentView {
        return VersionContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
