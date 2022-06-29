//
//  PersonDetailHeaderContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/05/22.
//

import UIKit

// MARK: - PersonDetailHeaderContentView

class PersonDetailHeaderContentView: UIView, UIContentView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet var avatarPlaceHolderLabel: UILabel! {
        didSet {
            avatarPlaceHolderLabel.font = .NOI.title3Semibold
        }
    }
    
    @IBOutlet private var fullnameLabel: UILabel! {
        didSet {
            fullnameLabel.font = .NOI.title1Semibold
        }
    }
    
    @IBOutlet private var companyLabel: UILabel! {
        didSet {
            companyLabel.font = .NOI.bodySemibold
        }
    }
    
    private var currentConfiguration: PersonDetailHeaderContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? PersonDetailHeaderContentConfiguration
            else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    init(configuration: PersonDetailHeaderContentConfiguration) {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    private func apply(configuration: PersonDetailHeaderContentConfiguration) {
        // Only apply configuration if new configuration and current
        // configuration are not the same
        guard currentConfiguration != configuration
        else { return }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Update image view
        imageView.image = configuration.image
        
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

private extension PersonDetailHeaderContentView {
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(PersonDetailHeaderContentView.self)",
            owner: self,
            options: nil
        )
        
        embedSubview(containerView)
    }
    
}

// MARK: - PersonDetailHeaderContentConfiguration

struct PersonDetailHeaderContentConfiguration: UIContentConfiguration, Hashable {
    
    /// The image to display.
    var image: UIImage?
    
    /// The fullname text.
    var fullname: String?
    
    /// An attributed variant of the fullname text.
    var fullnameAttributedText: NSAttributedString?
    
    /// Properties for configuring the fullname text.
    var fullnameTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.title1Semibold
    )
    
    /// The published date text.
    var company: String?
    
    /// An attributed variant of the published date text.
    var companyAttributedText: NSAttributedString?
    
    /// Properties for configuring the published date text.
    var companyTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.subheadlineRegular
    )
    
    /// The primary avatar's text.
    var avatarText: String?
    
    /// An attributed variant of the avatar's primary text.
    var avatarAttributedText: NSAttributedString?
    
    /// Properties for configuring the avatar text.
    var avatarTextProprieties = ContentConfiguration.TextProperties(
        font: .NOI.headlineSemibold
    )
    
    func makeContentView() -> UIView & UIContentView {
        return PersonDetailHeaderContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
