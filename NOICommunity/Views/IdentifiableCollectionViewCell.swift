//
//  IdentifiableCollectionViewCell.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 14/09/21.
//

import UIKit

class IdentifiableCollectionViewCell<T: Identifiable>: UICollectionViewCell {

    var identifiable: T!

    override func prepareForReuse() {
        super.prepareForReuse()
        identifiable = nil
    }
}
