//
//  NewsCardContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/05/22.
//

import UIKit

// MARK: - NewsCardContentView

class NewsCardContentView: UIView, UIContentView {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var publishedDateLabel: UILabel!
    
    @IBOutlet var badgeLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var abstractLabel: UILabel!
    
    @IBOutlet var badgeIsHiddenConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var badgeIsNotHiddenBadgeConstraints: [NSLayoutConstraint]!
    
    private var currentConfiguration: NewsCardContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? NewsCardContentConfiguration
            else { return }
            
            apply(configuration: newConfiguration)
        }
    }
    
    init(configuration: NewsCardContentConfiguration) {
        super.init(frame: .zero)
        
        configureViewHierarchy()
        
        apply(configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}

// MARK: Private APIs

private extension NewsCardContentView {
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(NewsCardContentView.self)",
            owner: self,
            options: nil
        )
        
        embedSubview(containerView)
    }
    
    private func apply(configuration: NewsCardContentConfiguration) {
        // Only apply configuration if new configuration and current
        // configuration are not the same
        guard currentConfiguration != configuration
        else { return }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Update image view
        imageView.image = configuration.image
        
        // Update author label
        authorLabel.setText(
            (configuration.authorAttributedText, configuration.authorText),
            textProperties: configuration.authorTextProprieties
        )
        
        // Update published date label
        publishedDateLabel.setText(
            (configuration.publishedDateAttributedText, configuration.publishedDateText),
            textProperties: configuration.publishedDateTextProprieties
        )
        
        // Update badge label
        badgeLabel.setText(
            (configuration.badgeAttributedText, configuration.badgeText),
            textProperties: configuration.badgeTextProprieties
        )
        
        if configuration.badgeAttributedText == nil && configuration.badgeText == nil {
            badgeLabel.isHidden = true
            NSLayoutConstraint.deactivate(badgeIsNotHiddenBadgeConstraints)
            NSLayoutConstraint.activate(badgeIsHiddenConstraints)
        } else {
            badgeLabel.isHidden = false
            NSLayoutConstraint.deactivate(badgeIsHiddenConstraints)
            NSLayoutConstraint.activate(badgeIsNotHiddenBadgeConstraints)
        }
        
        // Update title label
        titleLabel.setText(
            (configuration.titleAttributedText, configuration.titleText),
            textProperties: configuration.titleTextProprieties
        )
        
        // Update abstract label
        abstractLabel.setText(
            (configuration.abstractAttributedText, configuration.abstractText),
            textProperties: configuration.abstractTextProprieties
        )
    }
    
}

// MARK: - NewsCardContentConfiguration

struct NewsCardContentConfiguration: UIContentConfiguration, Hashable {
    
    /// The image to display.
    var image: UIImage?
    
    /// The author text.
    var authorText: String?
    
    /// An attributed variant of the author text.
    var authorAttributedText: NSAttributedString?
    
    /// Properties for configuring the author text.
    var authorTextProprieties = ContentConfiguration.TextProperties()
    
    /// The published date text.
    var publishedDateText: String?
    
    /// An attributed variant of the published date text.
    var publishedDateAttributedText: NSAttributedString?
    
    /// Properties for configuring the published date text.
    var publishedDateTextProprieties = ContentConfiguration.TextProperties()
    
    /// The primary badge's text.
    var badgeText: String?
    
    /// An attributed variant of the badge's primary text.
    var badgeAttributedText: NSAttributedString?
    
    /// Properties for configuring the badge text.
    var badgeTextProprieties = ContentConfiguration.TextProperties()
    
    /// The title text.
    var titleText: String?
    
    /// An attributed variant of the tille secondary text.
    var titleAttributedText: NSAttributedString?
    
    /// Properties for configuring the title text.
    var titleTextProprieties = ContentConfiguration.TextProperties()
    
    /// The abstract text.
    var abstractText: String?
    
    /// An attributed variant of the abstract text.
    var abstractAttributedText: NSAttributedString?
    
    /// Properties for configuring the abstract text.
    var abstractTextProprieties = ContentConfiguration.TextProperties()
    
    func makeContentView() -> UIView & UIContentView {
        return NewsCardContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
