// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  IndexPathAdditions.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/01/24.
//

import UIKit

extension UITableView {

    func isLatestIndexPath(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section == numberOfSections - 1
        else { return false }

        return indexPath.row == numberOfRows(inSection: indexPath.section) - 1
    }

    func isLastIndexPathInItsSection(_ indexPath: IndexPath) -> Bool {
        indexPath.row == numberOfRows(inSection: indexPath.section) - 1
    }
}

extension UICollectionView {

    func isLatestIndexPath(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section == numberOfSections - 1
        else { return false }

        return indexPath.item == numberOfItems(inSection: indexPath.section) - 1
    }

    func isLastIndexPathInItsSection(_ indexPath: IndexPath) -> Bool {
        indexPath.item == numberOfItems(inSection: indexPath.section) - 1
    }
}
