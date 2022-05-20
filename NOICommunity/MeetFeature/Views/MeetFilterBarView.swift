//
//  MeetFilterBarView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 01/06/22.
//

import UIKit

// MARK: - MeetFilterBarView

class MeetFilterBarView: UIView {
    
    @IBOutlet private(set) var filtersButton: UIButton! {
        didSet {
            filtersButton.setTitleColor(.noiPrimaryColor, for: .normal)
            filtersButton.setTitleColor(
                .noiPrimaryColor.withAlphaComponent(0.6),
                for: .highlighted
            )
            filtersButton.titleLabel?.font = .preferredFont(
                forTextStyle: .footnote,
                weight: .semibold
            )
            filtersButton.layer.cornerRadius = 2
        }
    }
        
    @IBOutlet private(set) var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = .localized("search_label")
        }
    }
    
    @IBOutlet private var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
}

// MARK: Private APIs

private extension MeetFilterBarView {
    
    func setup() {
        backgroundColor = .noiSecondaryBackgroundColor
        
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(MeetFilterBarView.self)",
            owner: self,
            options: nil
        )
        
        contentView.backgroundColor = .noiSecondaryBackgroundColor
        embedSubview(contentView)
    }
    
}
