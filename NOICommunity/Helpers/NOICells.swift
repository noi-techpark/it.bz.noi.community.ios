//
//  UIListContentConfiguration+NOI.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 15/10/21.
//

import UIKit

extension UIListContentConfiguration {
    
    static func noiCell() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 17,
            bottom: 0,
            trailing: 0
        )
        contentConfiguration.textProperties.color = .noiSecondaryColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        return contentConfiguration
    }
    
    static func noiValueCell() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.valueCell()
        contentConfiguration.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 17,
            bottom: 0,
            trailing: 0
        )
        contentConfiguration.textProperties.color = .noiSecondaryColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        return contentConfiguration
    }
    
    static func noiDetailsSubtitleCell() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 17,
            bottom: 0,
            trailing: 0
        )
        
        contentConfiguration.textProperties.color = .noiSecondaryColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .footnote,
            weight: .semibold
        )
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        
        contentConfiguration.secondaryTextProperties.color = .noiSecondaryColor
        contentConfiguration.secondaryTextProperties.font = .preferredFont(
            forTextStyle: .body
        )
        contentConfiguration.secondaryTextProperties.numberOfLines = 0
        contentConfiguration.secondaryTextProperties.adjustsFontForContentSizeCategory = true
        
        return contentConfiguration
    }

    static func noiGroupedHeader() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.plainHeader()
        contentConfiguration.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 17,
            bottom: 0,
            trailing: 0
        )
        
        contentConfiguration.textProperties.color = .noiSecondaryColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        return contentConfiguration
    }
}

extension UICellAccessory {
    
    static func noiDisclosureIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: UIImage(named: "ic_arrow"))
        imageView.bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
        let viewConfig = CustomViewConfiguration(
            customView: imageView,
            placement: .trailing(displayed: .whenNotEditing),
            reservedLayoutWidth: nil,
            tintColor: .noiSecondaryColor,
            maintainsFixedSize: true
        )
        return .customView(configuration: viewConfig)
    }
    
    static func noiCopyIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: UIImage(named: "ic_copy"))
        imageView.bounds = CGRect(x: 0, y: 0, width: 17, height: 21)
        let viewConfig = CustomViewConfiguration(
            customView: imageView,
            placement: .trailing(displayed: .whenNotEditing),
            reservedLayoutWidth: nil,
            tintColor: .noiSecondaryColor,
            maintainsFixedSize: true
        )
        return .customView(configuration: viewConfig)
    }
    
    static func noiCopiedIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: UIImage(named: "ic_copied"))
        imageView.bounds = CGRect(x: 0, y: 0, width: 17, height: 21)
        let viewConfig = CustomViewConfiguration(
            customView: imageView,
            placement: .trailing(displayed: .whenNotEditing),
            reservedLayoutWidth: nil,
            tintColor: .noiSecondaryColor,
            maintainsFixedSize: true
        )
        return .customView(configuration: viewConfig)
    }
    
    static func noiLogoutIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: UIImage(named: "ic_exit_arrow"))
        imageView.bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
        let viewConfig = CustomViewConfiguration(
            customView: imageView,
            placement: .leading(displayed: .whenNotEditing),
            reservedLayoutWidth: nil,
            tintColor: .noiSecondaryColor,
            maintainsFixedSize: true
        )
        return .customView(configuration: viewConfig)
    }
    
}

extension UIBackgroundConfiguration {
    static func noiListPlainCell(for cell: UICollectionViewCell) -> UIBackgroundConfiguration {
        var backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
        backgroundConfiguration.backgroundColorTransformer = UIConfigurationColorTransformer { [weak cell] color in
            switch cell?.configurationState {
            case let configurationState? where configurationState.isSelected || configurationState.isHighlighted:
                return color
            default:
                return .noiTertiaryBackgroundColor
            }
        }
        return backgroundConfiguration
    }
}
