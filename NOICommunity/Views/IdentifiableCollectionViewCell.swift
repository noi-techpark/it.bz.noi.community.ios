//
//  IdentifiableCollectionViewCell.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit

class IdentifiableCollectionViewCell<T>: UICollectionViewCell, Identifiable {
    var id: T!

    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
    }
}
