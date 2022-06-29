//
//  FiltersBarView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 15/10/21.
//

import UIKit

// MARK: - FiltersBarView

class FiltersBarView: UIView {

    @IBOutlet private(set) var scrollView: UIScrollView!
    @IBOutlet private(set) var filtersButton: UIButton! {
        didSet {
            filtersButton.setTitleColor(.noiPrimaryColor, for: .normal)
            filtersButton.setTitleColor(
                .noiPrimaryColor.withAlphaComponent(0.6),
                for: .highlighted
            )
            filtersButton.titleLabel?.font = .NOI.caption1Semibold
            filtersButton.layer.cornerRadius = 2
        }
    }
    
    lazy var dateIntervalsControl: UISegmentedControl = {
        let activeColor = UIColor.noiSecondaryColor
        let color = activeColor.withAlphaComponent(0.5)
        var builder = SegmentedControlBuilder(
            imageFactory: NoiSegmentedControlImageFactory()
        )
        builder.tintColor = color
        builder.selectedTintedColor = activeColor
        builder.font = .NOI.caption1Semibold
        builder.selectedFont = builder.font
        builder.class = SegmentedControl.self
        let segmentedControl = builder.makeSegmentedControl(
            items: DateIntervalFilter.allCases.map(\.localizedString)
        )
        segmentedControl.clipsToBounds = false
        return segmentedControl
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
        dateIntervalsControl.addTarget(
            self,
            action: #selector(selectedFilterValueDidChange(sender:)),
            for: .valueChanged
        )
    }

    func configureScrollView() {
        scrollView.contentInset = .init(
            top: 0,
            left: 17,
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
                .constraint(equalTo: contentGuide.heightAnchor)
        ])
    }

}

// MARK: - FiltersBarView.SegmentedControlImageFactory

private extension FiltersBarView {

    @objc func selectedFilterValueDidChange(sender: UISegmentedControl) {
        let selectedSegmentIndex = sender.selectedSegmentIndex
        let convertRect: (UIView) -> CGRect = {
            $0.convert($0.frame, to: self.scrollView)
        }
        let selectedControls = dateIntervalsControl
            .recursiveSubviews { $0 is UILabel }
            .sorted { convertRect($0).minX < convertRect($1).minX }
        let selectedControl = selectedControls[selectedSegmentIndex]
        scrollView.scrollToView(
            view: selectedControl,
            position: .middle,
            animated: true
        )
    }

    struct NoiSegmentedControlImageFactory: SegmentedControlImageFactory {

        var height: CGFloat = 40
        var spacing: CGFloat = 5
        var selectedStates: [UIControl.State] = [.selected, .highlighted]
        var lineWidth: CGFloat = 2
        var fillColor = UIColor.noiPrimaryColor
        var lineColor = UIColor.noiInactiveColor
        var selectedLineColor = UIColor.noiSecondaryColor
        var cornerRadius: CGFloat = 2
        var edgeOffset: CGFloat {
            0
        }

        func background(for state: UIControl.State) -> UIImage? {
            let imageSize = CGSize(width: cornerRadius * 2 + 1 , height: height)
            let renderer = UIGraphicsImageRenderer(size: imageSize)

            return renderer.image { context in
                let canvasRect = CGRect(origin: .zero, size: imageSize)
                let roundedRectPath = UIBezierPath(
                    roundedRect: canvasRect.insetBy(
                        dx: lineWidth / 2,
                        dy: lineWidth / 2
                    ),
                    cornerRadius: cornerRadius
                )
                roundedRectPath.lineWidth = lineWidth
                strokeColor(for: state).setStroke()
                roundedRectPath.stroke()
                fillColor.setFill()
                roundedRectPath.fill()
            }
        }

        func divider(
            leftState: UIControl.State,
            rightState: UIControl.State
        ) -> UIImage? {
            let halfRoundedRectSize = CGSize(
                width: cornerRadius + 1,
                height: height
            )
            let cornerRadii = CGSize(width: cornerRadius, height: cornerRadius)
            let imageSize = CGSize(
                width: halfRoundedRectSize.width * 2 + spacing,
                height: halfRoundedRectSize.height
            )
            let renderer = UIGraphicsImageRenderer(size: imageSize)

            let image = renderer.image { context in
                fillColor.setFill()

                let leftHalfRoundedRectRect = CGRect(
                    origin: .zero,
                    size: halfRoundedRectSize
                )
                let leftHalfRoundedRectPath = UIBezierPath(
                    roundedRect: leftHalfRoundedRectRect.insetBy(
                        dx: lineWidth / 2,
                        dy: lineWidth / 2
                    ),
                    byRoundingCorners: [.topRight, .bottomRight],
                    cornerRadii: cornerRadii
                )
                leftHalfRoundedRectPath.lineWidth = lineWidth
                strokeColor(for: leftState).setStroke()
                leftHalfRoundedRectPath.stroke()
                leftHalfRoundedRectPath.fill()

                let rightHalfRoundedRectRect = leftHalfRoundedRectRect
                    .offsetBy(
                        dx: leftHalfRoundedRectRect.maxX + spacing,
                        dy: 0
                    )
                let rightHalfRoundedRectPath = UIBezierPath(
                    roundedRect: rightHalfRoundedRectRect.insetBy(
                        dx: lineWidth / 2,
                        dy: lineWidth / 2
                    ),
                    byRoundingCorners: [.topLeft, .bottomLeft],
                    cornerRadii: cornerRadii
                )
                rightHalfRoundedRectPath.lineWidth = lineWidth
                strokeColor(for: rightState).setStroke()
                rightHalfRoundedRectPath.stroke()
                rightHalfRoundedRectPath.fill()
            }

            return image.cropped(with: CGRect(
                origin: .zero,
                size: imageSize
            ).insetBy(dx: lineWidth / 2, dy: 0)
            )
        }

        private func strokeColor(for state: UIControl.State) -> UIColor {
            switch state {
            case .selected,
                    .highlighted,
                [.selected, .highlighted]:
                return selectedLineColor
            default:
                return lineColor
            }
        }

    }

}

private extension UIImage {

    func cropped(with cropRect: CGRect) -> UIImage {
        var rect = cropRect
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.width *= scale
        rect.size.height *= scale

        let croppedCGImage = cgImage!.cropping(
            to: rect
        )!
        return UIImage(
            cgImage: croppedCGImage,
            scale: scale,
            orientation: imageOrientation
        )
    }

}
