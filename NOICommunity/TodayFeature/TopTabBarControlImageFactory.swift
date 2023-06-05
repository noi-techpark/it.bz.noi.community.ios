// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NoiSegmentedControlImageFactory.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 22/03/22.
//

import UIKit

struct TopTabBarControlImageFactory: SegmentedControlImageFactory {
    
    var height: CGFloat = 40
    var selectedPadding: CGFloat = 2
    var fillColor = UIColor.noiInactive2Color
    var selectedFillColor = UIColor.noiPrimaryColor
    var cornerRadius: CGFloat = 2
    var edgeOffset: CGFloat {
        0
    }
    
    func background(for state: UIControl.State) -> UIImage? {
        let isSelectedState = state.contains(.highlighted) ||
        state.contains(.selected)
        var imageSize = CGSize(
            width: cornerRadius * 2,
            height: height
        )
        if isSelectedState {
            imageSize.width += selectedPadding * 2
        }
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let canvasRect = CGRect(origin: .zero, size: imageSize)
            let roundedRectPath = UIBezierPath(
                roundedRect: canvasRect,
                cornerRadius: cornerRadius
            )
            fillColor.setFill()
            roundedRectPath.fill()
            
            if isSelectedState {
                let selectedRoundedRectPath = UIBezierPath(
                    roundedRect: canvasRect.insetBy(
                        dx: selectedPadding,
                        dy: selectedPadding
                    ),
                    cornerRadius: cornerRadius
                )
                fillColor(for: state).setFill()
                selectedRoundedRectPath.fill()
            }
        }
    }
    
    func divider(
        leftState: UIControl.State,
        rightState: UIControl.State
    ) -> UIImage? {
        UIImage()
    }
    
    private func fillColor(for state: UIControl.State) -> UIColor {
        switch state {
        case .selected,
                .highlighted,
            [.selected, .highlighted]:
            return selectedFillColor
        default:
            return fillColor
        }
    }
    
}
