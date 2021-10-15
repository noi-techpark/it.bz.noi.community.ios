//
//  FiltersBarView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 15/10/21.
//

import UIKit

// MARK: - FiltersBarView

class FiltersBarView: UIView {

    @IBOutlet var scrollView: UIScrollView!
    
    lazy var dateIntervalsControl: UISegmentedControl = {
        let activeColor = UIColor.noiSecondaryColor
        let color = activeColor.withAlphaComponent(0.5)
        var imageFactory = UnderlineSegmentedControlImageFactory()
        imageFactory.size.height = 40
        imageFactory.lineWidth = 2
        imageFactory.selectedLineWidth = 2
        imageFactory.lineColor = color
        imageFactory.selectedLineColor = activeColor
        imageFactory.extraSpacing = 12
        var builder = SegmentedControlBuilder(
            imageFactory: imageFactory
        )
        builder.tintColor = color
        builder.selectedTintedColor = activeColor
        builder.font = .boldSystemFont(ofSize: 19)
        builder.font = .boldSystemFont(ofSize: 19)
        builder.selectedFont = builder.font
        builder.class = SegmentedControl.self
        return builder.makeSegmentedControl(
            items: DateIntervalFilter.allCases.map(\.localizedString)
        )
    }()

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

private extension FiltersBarView {
    class SegmentedControl: UISegmentedControl {

        // Removes swipe gesture
        override func gestureRecognizerShouldBegin(
            _ gestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Force a square shape
            layer.cornerRadius = 0
        }
    }

    func setup() {
        backgroundColor = .noiSecondaryBackgroundColor
        
        // Load containerView from its xib and embed it as a subview
        Bundle.main.loadNibNamed(
            "\(FiltersBarView.self)",
            owner: self,
            options: nil
        )

        embedSubview(contentView)
        configureScrollView()
    }

    func configureScrollView() {
        scrollView.contentInset = .init(
            top: 0,
            left: 0,
            bottom: 0,
            right: 17
        )
        scrollView.addSubview(dateIntervalsControl)
        dateIntervalsControl.translatesAutoresizingMaskIntoConstraints = false
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        NSLayoutConstraint.activate([
            dateIntervalsControl.leadingAnchor
                .constraint(equalTo: contentGuide.leadingAnchor),
            dateIntervalsControl.trailingAnchor
                .constraint(equalTo: contentGuide.trailingAnchor),
            dateIntervalsControl.bottomAnchor
                .constraint(equalTo: contentGuide.bottomAnchor),
            dateIntervalsControl.topAnchor
                .constraint(equalTo: contentGuide.topAnchor),
            frameGuide.heightAnchor
                .constraint(equalTo: contentGuide.heightAnchor),
        ])
    }

}
