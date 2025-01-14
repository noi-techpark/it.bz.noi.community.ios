// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

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
	private var overlappingImageView: UIImageView!

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

		overlappingImageView = UIImageView()
		overlappingImageView.clipsToBounds = true
		addSubview(overlappingImageView)

		overlappingImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			overlappingImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			overlappingImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
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

		// Update overlapping image view
		overlappingImageView.image = configuration.overlappingImage
		overlappingImageView
			.apply(imageProperties: configuration.overlappingImageProperties)
		overlappingImageView.isHidden = configuration.overlappingImage == nil
    }

}

// MARK: - ImageContentConfiguration

struct ImageContentConfiguration: UIContentConfiguration, Hashable {

	/// The image to display.
	var image: UIImage?

	/// Properties for configuring the image.
	var imageProperties = ImageProperties()

	/// The overlapping image to display.
	var overlappingImage: UIImage?

	/// Properties for configuring the overlapping image.
	var overlappingImageProperties = ImageProperties()

	func makeContentView() -> UIView & UIContentView {
		return ImageContentView(configuration: self)
	}

	func updated(for state: UIConfigurationState) -> Self {
		return self
	}
}

extension ImageContentConfiguration {
    struct ImageProperties: Hashable {
        var contentMode: UIView.ContentMode = .scaleAspectFill
		var tintColor: UIColor? = nil
    }
}

private extension UIImageView {
    func apply(imageProperties: ImageContentConfiguration.ImageProperties) {
        contentMode = imageProperties.contentMode
		tintColor = imageProperties.tintColor
    }
}
