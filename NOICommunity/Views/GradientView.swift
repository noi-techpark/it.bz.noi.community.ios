//
//  GradientView.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 15/04/22.
//

import UIKit

@IBDesignable
open class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = .black {
        didSet { updateColors() }
    }
    
    @IBInspectable var secondColor: UIColor = .gray {
        didSet { updateColors() }
    }
    
    @IBInspectable var thirdColor: UIColor = .white {
        didSet { updateColors() }
    }
    
    @IBInspectable var lastColor: UIColor = .white {
        didSet { updateColors() }
    }
    
    @IBInspectable var firstLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var secondLocation: CGFloat = 0.33 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var thirdLocation: CGFloat = 0.66 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var lastLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    
    @IBInspectable var horizontalMode: Bool = false {
        didSet { updatePoints() }
    }
    
    @IBInspectable var diagonalMode: Bool = false {
        didSet { updatePoints() }
    }
    
    override public class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    override open func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updatePoints()
        updateLocations()
        updateColors()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}

private extension GradientView {
    
    var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ?
                .init(x: 1, y: 0) :
                .init(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ?
                .init(x: 0, y: 1) :
                .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ?
                .init(x: 0, y: 0) :
                .init(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ?
                .init(x: 1, y: 1) :
                .init(x: 0.5, y: 1)
        }
    }
    
    func updateLocations() {
        gradientLayer.locations = [
            firstLocation,
            secondLocation,
            thirdLocation,
            lastLocation
        ]
            .map { $0 as NSNumber }
    }
    
    func updateColors() {
        gradientLayer.colors = [
            firstColor,
            secondColor,
            thirdColor,
            lastColor
        ]
            .map(\.cgColor)
    }
    
}

