//
//  EventCardContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit

// MARK: - EventCardContentView

class EventCardContentView: UIView, UIContentView {
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var leadingDetailTextLabel: UILabel!
    @IBOutlet var trailingDetailTextLabel: UILabel!
    @IBOutlet var tertiaryTextLabel: UILabel?
    @IBOutlet var badgeTextLabel: UILabel!
    @IBOutlet var badgeDetailTextLabel: UILabel!

    private var currentConfiguration: EventCardContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? EventCardContentConfiguration
            else { return }

            apply(configuration: newConfiguration)
        }
    }

    init(configuration: EventCardContentConfiguration) {
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

private extension EventCardContentView {
    func configureViewHierarchy() {
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(EventCardContentView.self)",
            owner: self,
            options: nil
        )

        embedSubview(containerView)
    }

    private func apply(configuration: EventCardContentConfiguration) {
        // Only apply configuration if new configuration and current
        // configuration are not the same
        guard currentConfiguration != configuration
        else { return }

        // Replace current configuration with new configuration
        currentConfiguration = configuration

        // Update image view
        imageView.image = configuration.image

        // Update text label
        textLabel.setAttributedText(
            configuration.attributedText,
            or: configuration.text
        )
        textLabel.apply(textProperties: configuration.textProprieties)

        // Update leading detail text label
        leadingDetailTextLabel.setAttributedText(
            configuration.leadingSecondaryAttributedText,
            or: configuration.leadingSecondaryText
        )
        leadingDetailTextLabel.apply(
            textProperties: configuration.leadingSecondaryTextProprieties
        )

        // Update trailing detail text label
        trailingDetailTextLabel.setAttributedText(
            configuration.trailingSecondaryAttributedText,
            or: configuration.trailingSecondaryText
        )
        trailingDetailTextLabel.apply(
            textProperties: configuration.trailingSecondaryTextProprieties
        )

        // Update badge text label
        badgeTextLabel.setAttributedText(
            configuration.badgeAttributedText,
            or: configuration.badgeText
        )
        badgeTextLabel.apply(textProperties: configuration.badgeTextProprieties)

        // Update foo tertiary text label
        tertiaryTextLabel?.setAttributedText(
            configuration.tertiaryAttributedText,
            or: configuration.tertiaryText
        )
        tertiaryTextLabel?.apply(
            textProperties: configuration.tertiaryTextProprieties
        )
    }
}

// MARK: - EventCardContentConfiguration

struct EventCardContentConfiguration: UIContentConfiguration, Hashable {

    /// The image to display.
    var image: UIImage?

    /// The primary text.
    var text: String?

    /// An attributed variant of the primary text.
    var attributedText: NSAttributedString?

    /// Properties for configuring the primary text.
    var textProprieties = TextProperties()

    /// The leading secondary text.
    var leadingSecondaryText: String?

    /// An attributed variant of the leading secondary text.
    var leadingSecondaryAttributedText: NSAttributedString?

    /// Properties for configuring the leading secondary text.
    var leadingSecondaryTextProprieties = TextProperties()

    /// The trailing secondary text.
    var trailingSecondaryText: String?

    /// An attributed variant of the trailing secondary text.
    var trailingSecondaryAttributedText: NSAttributedString?

    /// Properties for configuring the trailing secondary text.
    var trailingSecondaryTextProprieties = TextProperties()

    /// The tertiary text.
    var tertiaryText: String?

    /// An attributed variant of the tertiary text.
    var tertiaryAttributedText: NSAttributedString?

    /// Properties for configuring the tertiary text.
    var tertiaryTextProprieties = TextProperties()

    /// The primary badge's text.
    var badgeText: String?

    /// An attributed variant of the badge's primary text.
    var badgeAttributedText: NSAttributedString?

    /// Properties for configuring the badge text.
    var badgeTextProprieties = TextProperties()

    func makeContentView() -> UIView & UIContentView {
        return EventCardContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

extension EventCardContentConfiguration {
    struct TextProperties: Hashable {
        /// The maximum number of lines for the text.
        var numberOfLines: Int = 1
    }
}

// MARK: - UILabel+setAttributedText

private extension UILabel {
    func setAttributedText(
        _ attributedText: NSAttributedString?,
        or text: String?
    ) {
        if let attributedText = attributedText {
            self.attributedText = attributedText
        } else {
            self.text = text
        }
    }

    func apply(textProperties: EventCardContentConfiguration.TextProperties) {
        numberOfLines = textProperties.numberOfLines
    }
}
