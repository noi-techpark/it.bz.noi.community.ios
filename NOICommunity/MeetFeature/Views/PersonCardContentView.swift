// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  PersonCardContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/05/22.
//

import UIKit

// MARK: - PersonCardContentView

class PersonCardContentView: UIView, UIContentView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var avatarPlaceHolderLabel: UILabel! {
        didSet {
            avatarPlaceHolderLabel.font = .NOI.dynamic.bodySemibold
        }
    }
    
    @IBOutlet var fullnameLabel: UILabel! {
        didSet {
            fullnameLabel.font = .NOI.dynamic.footnoteSemibold
        }
    }
    
    @IBOutlet var companyLabel: UILabel! {
        didSet {
            companyLabel.font = .NOI.dynamic.bodyRegular
        }
    }
    
    private var currentConfiguration: PersonCardContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? PersonCardContentConfiguration
            else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    init(configuration: PersonCardContentConfiguration) {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    private func apply(configuration: PersonCardContentConfiguration) {
        // Only apply configuration if new configuration and current
        // configuration are not the same
        guard currentConfiguration != configuration
        else { return }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Update fullname label
        fullnameLabel.setText(
            (configuration.fullnameAttributedText, configuration.fullname),
            textProperties: configuration.fullnameTextProprieties
        )
        
        // Update company label
        companyLabel.setText(
            (configuration.companyAttributedText, configuration.company),
            textProperties: configuration.companyTextProprieties
        )
        
        // Update avatar label
        avatarPlaceHolderLabel.setText(
            (configuration.avatarAttributedText, configuration.avatarText),
            textProperties: configuration.avatarTextProprieties
        )
    }
    
}

// MARK: Private APIs

private extension PersonCardContentView {
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(PersonCardContentView.self)",
            owner: self,
            options: nil
        )
        
        embedSubview(containerView)
    }
    
}

// MARK: - PersonCardContentConfiguration

struct PersonCardContentConfiguration: UIContentConfiguration, Hashable {
    
    /// The image to display.
    var image: UIImage?
    
    /// The fullname text.
    var fullname: String?
    
    /// An attributed variant of the fullname text.
    var fullnameAttributedText: NSAttributedString?
    
    /// Properties for configuring the fullname text.
    var fullnameTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.dynamic.footnoteSemibold
    )
    
    /// The published date text.
    var company: String?
    
    /// An attributed variant of the published date text.
    var companyAttributedText: NSAttributedString?
    
    /// Properties for configuring the published date text.
    var companyTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.dynamic.bodyRegular
    )
    
    /// The primary avatar's text.
    var avatarText: String?
    
    /// An attributed variant of the avatar's primary text.
    var avatarAttributedText: NSAttributedString?
    
    /// Properties for configuring the avatar text.
    var avatarTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.fixed.bodySemibold
    )
    
    func makeContentView() -> UIView & UIContentView {
        return PersonCardContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
