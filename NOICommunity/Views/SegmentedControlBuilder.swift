//
//  File.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 20/09/21.
//

import UIKit

// MARK: - SegmentedControlFactory

protocol SegmentedControlImageFactory {
    func background(for state: UIControl.State) -> UIImage?

    func divider(
        leftState: UIControl.State,
        rightState: UIControl.State
    ) -> UIImage?
}

extension SegmentedControlImageFactory {
    func background(for state: UIControl.State) -> UIImage? { nil}
    func divider(
        leftState: UIControl.State,
        rightState: UIControl.State
    ) -> UIImage? { nil }
}

// MARK: - DefaultSegmentedControlImageFactory

struct DefaultSegmentedControlImageFactory: SegmentedControlImageFactory {}

// MARK: - SegmentedControlBuilder

struct SegmentedControlBuilder {
    var `class`: AnyClass = UISegmentedControl.self
    var selectedStates: [UIControl.State] = [.selected, .highlighted]
    var font = UIFont.systemFont(ofSize: 14)
    var selectedFont = UIFont.boldSystemFont(ofSize: 14)
    var tintColor = UIColor.white
    var selectedTintedColor = UIColor.white.withAlphaComponent(0.5)
    var apportionsSegmentWidthsByContent = true

    private let imageFactory: SegmentedControlImageFactory

    init(imageFactory: SegmentedControlImageFactory =
         DefaultSegmentedControlImageFactory()) {
        self.imageFactory = imageFactory
    }

    func makeSegmentedControl(items: [String]) -> UISegmentedControl {
        let segmentedControl = make()
        items.reversed().forEach {
            segmentedControl.insertSegment(
                withTitle: $0,
                at: 0,
                animated: false
            )
        }
        configureSegmentedControl(segmentedControl)
        return segmentedControl
    }

    func makeSegmentedControl(items: [UIImage]) -> UISegmentedControl {
        let segmentedControl = make()
        items.reversed().forEach {
            segmentedControl.insertSegment(
                with: $0,
                at: 0,
                animated: false
            )
        }
        configureSegmentedControl(segmentedControl)
        return segmentedControl
    }
}

// MARK: Private APIs

private extension SegmentedControlBuilder {
    func make() -> UISegmentedControl {
        let segmentedControlClass = `class` as! UISegmentedControl.Type
        return segmentedControlClass.init()
    }
    func background(for state: UIControl.State) -> UIImage? {
        imageFactory.background(for: state)
    }

    func divider(
        leftState: UIControl.State,
        rightState: UIControl.State
    ) -> UIImage? {
        imageFactory.divider(leftState: leftState, rightState: rightState)
    }

    func configureSegmentedControl(
        _ segmentedControl: UISegmentedControl
    ) {
        segmentedControl
            .apportionsSegmentWidthsByContent = apportionsSegmentWidthsByContent
        segmentedControl.tintColor = tintColor
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.setTitleTextAttributes(
            [
                .font : font,
                .foregroundColor: tintColor
            ],
            for: .normal
        )

        selectedStates.forEach { state in
            segmentedControl.setTitleTextAttributes(
                [
                    .font : selectedFont,
                    .foregroundColor: selectedTintedColor
                ],
                for: state
            )
        }

        let controlStates: [UIControl.State] = [
            .normal,
            .selected,
            .highlighted,
            [.highlighted, .selected]
        ]
        controlStates.forEach { state in
            let image = background(for: state)
            segmentedControl.setBackgroundImage(
                image,
                for: state,
                barMetrics: .default
            )

            controlStates.forEach { state2 in
                let image = divider(leftState: state, rightState: state2)
                segmentedControl.setDividerImage(
                    image,
                    forLeftSegmentState: state,
                    rightSegmentState: state2,
                    barMetrics: .default
                )
            }
        }
    }
}

// MARK: - UnderlineSegmentedControlImageFactory

struct UnderlineSegmentedControlImageFactory: SegmentedControlImageFactory {
    var size = CGSize(width: 1, height: 29)
    var selectedStates: [UIControl.State] = [.selected, .highlighted]
    var lineWidth: CGFloat = 1
    var selectedLineWidth: CGFloat = 2
    var lineColor = UIColor.white.withAlphaComponent(0.5)
    var selectedLineColor = UIColor.white
    var extraSpacing: CGFloat = 8

    func background(for state: UIControl.State) -> UIImage? {
        let (color, lineWidth) = colorAndLineWidth(for: state)
        let rect = CGRect(
            x: 0,
            y: size.height - lineWidth,
            width: size.width,
            height: lineWidth
        )
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(rect)
        }
    }

    func divider(
        leftState: UIControl.State,
        rightState: UIControl.State
    ) -> UIImage? {
        let (leftColor, leftLineWidth) = colorAndLineWidth(for: leftState)
        let (rightColor, rightLineWidth) = colorAndLineWidth(for: rightState)
        let size = CGSize(width: extraSpacing, height: size.height)
        let leftRect = CGRect(
            x: 0,
            y: size.height - leftLineWidth,
            width: size.width / 2,
            height: leftLineWidth
        )
        let rightRect = CGRect(
            x: size.width / 2,
            y: size.height - rightLineWidth,
            width: size.width / 2,
            height: rightLineWidth
        )

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            leftColor.setFill()
            context.fill(leftRect)

            rightColor.setFill()
            context.fill(rightRect)
        }
    }
}

// MARK: Private APIs

private extension UnderlineSegmentedControlImageFactory {
    func colorAndLineWidth(
        for state: UIControl.State
    ) -> (color: UIColor, lineWidth: CGFloat) {
        switch state {
        case .selected,
                .highlighted,
            [.selected, .highlighted]:
            return (selectedLineColor, selectedLineWidth)
        default:
            return (lineColor, lineWidth)
        }
    }
}
