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
    
    @IBOutlet var authorLabel: UILabel! {
        didSet {
            authorLabel.font = .preferredFont(
                forTextStyle: .body,
                weight: .semibold
            )
        }
    }
    
    @IBOutlet var publishedDateLabel: UILabel!
    
    @IBOutlet var badgeLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .preferredFont(
                forTextStyle: .body,
                weight: .semibold
            )
        }
    }
    
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
    var authorTextProprieties = TextProperties()
    
    /// The published date text.
    var publishedDateText: String?
    
    /// An attributed variant of the published date text.
    var publishedDateAttributedText: NSAttributedString?
    
    /// Properties for configuring the published date text.
    var publishedDateTextProprieties = TextProperties()
    
    /// The primary badge's text.
    var badgeText: String?
    
    /// An attributed variant of the badge's primary text.
    var badgeAttributedText: NSAttributedString?
    
    /// Properties for configuring the badge text.
    var badgeTextProprieties = TextProperties()
    
    /// The title text.
    var titleText: String?
    
    /// An attributed variant of the tille secondary text.
    var titleAttributedText: NSAttributedString?
    
    /// Properties for configuring the title text.
    var titleTextProprieties = TextProperties()
    
    /// The abstract text.
    var abstractText: String?
    
    /// An attributed variant of the abstract text.
    var abstractAttributedText: NSAttributedString?
    
    /// Properties for configuring the abstract text.
    var abstractTextProprieties = TextProperties()
    
    func makeContentView() -> UIView & UIContentView {
        return NewsCardContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

extension NewsCardContentConfiguration {
    struct TextProperties: Hashable {
        /// The maximum number of lines for the text.
        var numberOfLines: Int = 0
        
        /// The transform to apply to the text.
        var transform: UIListContentConfiguration.TextProperties.TextTransform = .none
    }
}

// MARK: - UILabel+setAttributedText

private extension UILabel {
    
    func setText(
        _ textInfos: (NSAttributedString?, String?),
        textProperties: NewsCardContentConfiguration.TextProperties
    ) {
        let (attributedTextOrNil, textOrNil) = textInfos
        
        if var attributedText = attributedTextOrNil {
            switch textProperties.transform {
            case .none:
                break
            case .capitalized:
                attributedText = attributedText.capitalized()
            case .lowercase:
                attributedText = attributedText.lowercased()
            case .uppercase:
                attributedText = attributedText.uppercased()
            @unknown default:
                break
            }
            
            self.attributedText = attributedText
        } else if var text = textOrNil {
            switch textProperties.transform {
            case .none:
                break
            case .capitalized:
                text = text.capitalized
            case .lowercase:
                text = text.lowercased()
            case .uppercase:
                text = text.uppercased()
            @unknown default:
                break
            }
            
            self.text = text
        }
        
        numberOfLines = textProperties.numberOfLines
    }
    
}

extension NSAttributedString {
    
    func capitalized() -> NSAttributedString {
        transform { $0.capitalized }
    }
    
    func uppercased() -> NSAttributedString {
        transform { $0.uppercased() }
    }
    
    func lowercased() -> NSAttributedString {
        transform { $0.lowercased()}
    }
    
    private func transform(_ block: (String) -> String) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        
        self.enumerateAttributes(
            in: NSRange(location: 0, length: length),
            options: [.longestEffectiveRangeNotRequired]
        ) { _, range, _ in
            let currentText = (string as NSString).substring(with: range)
            result.replaceCharacters(in: range, with: block(currentText))
        }
        
        return result
    }
    
}
