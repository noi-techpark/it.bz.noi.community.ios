//
//  ImageContentView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 29/09/21.
//

import UIKit

// MARK: - ImageContentView

class ImageContentView: UIView, UIContentView {
    private var imageView: UIImageView!

    private var currentConfiguration: ImageContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? ImageContentConfiguration
            else { return }

            apply(configuration: newConfiguration)
        }
    }

    init(configuration: ImageContentConfiguration) {
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

private extension ImageContentView {
    func configureViewHierarchy() {
        imageView = UIImageView()
        imageView.clipsToBounds = true
        embedSubview(imageView)
    }

    private func apply(configuration: ImageContentConfiguration) {
        // Only apply configuration if new configuration and current
        // configuration are not the same
        guard currentConfiguration != configuration
        else { return }

        // Replace current configuration with new configuration
        currentConfiguration = configuration

        // Update image view
        imageView.image = configuration.image
        imageView.apply(imageProperties: configuration.imageProperties)
    }
}

// MARK: - ImageContentConfiguration

struct ImageContentConfiguration: UIContentConfiguration, Hashable {

    /// The image to display.
    var image: UIImage?

    /// Properties for configuring the image.
    var imageProperties = ImageProperties()

    func makeContentView() -> UIView & UIContentView {
        return ImageContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

extension ImageContentConfiguration {
    struct ImageProperties: Hashable {
        /// The maximum number of lines for the text.
        var contentMode: UIView.ContentMode = .scaleToFill
    }
}

private extension UIImageView {
    func apply(imageProperties: ImageContentConfiguration.ImageProperties) {
        contentMode = imageProperties.contentMode
    }
}
