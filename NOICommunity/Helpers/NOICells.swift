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
        contentConfiguration.textProperties.color = .noiSecondaryColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .body,
            weight: .semibold
        )
        contentConfiguration.textProperties.numberOfLines = 0
        contentConfiguration.textProperties.adjustsFontForContentSizeCategory = true
        return contentConfiguration
    }
    
    static func noiDestructiveCell() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.noiCell()
        contentConfiguration.textProperties.color = .noiDestructiveColor
        contentConfiguration.textProperties.font = .preferredFont(
            forTextStyle: .body,
            weight: .bold
        )
        return contentConfiguration
    }

    static func noiGroupedHeader() -> UIListContentConfiguration {
        var contentConfiguration = UIListContentConfiguration.plainHeader()
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
    
    static func noiLogoutIndicator() -> UICellAccessory {
        let imageView = UIImageView(image: UIImage(named: "ic_exit_arrow"))
        imageView.bounds = CGRect(x: 0, y: 0, width: 20, height: 15)
        let viewConfig = CustomViewConfiguration(
            customView: imageView,
            placement: .leading(displayed: .whenNotEditing),
            reservedLayoutWidth: nil,
            tintColor: .noiDestructiveColor,
            maintainsFixedSize: true
        )
        return .customView(configuration: viewConfig)
    }
    
}

extension UIBackgroundConfiguration {
    static func noiListPlainCell(for cell: UICollectionViewListCell) -> UIBackgroundConfiguration {
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
