//
//  InteractiveTransition.swift
//  ViewTransition
//
//  Created by tskim on 24/08/2019.
//  Copyright © 2019 hucet. All rights reserved.
//
import UIKit

internal class InteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    
    private var animator: UIViewControllerAnimatedTransitioning
    private var gesture: UIGestureRecognizer
    var presented: UIViewController?
    
    private weak var transitionContext: UIViewControllerContextTransitioning?
    
    // MARK: - Initialization
    
    init(
        gesture: UIGestureRecognizer,
        animator: UIViewControllerAnimatedTransitioning,
        presented: UIViewController
        ) {
        guard InteractiveTransition.isSupported(animator: animator) else {
            fatalError("Warning! Animator must implement interruptibleAnimator method to be used with SwipeInteractiveTransition!")
        }
        self.gesture = gesture
        self.animator = animator
        self.presented = presented
        super.init()
        gesture.addTarget(self, action: #selector(onGestureRecognized))
    }
    
    // MARK: - UIPercentDrivenInteractiveTransition
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        print("startInteractiveTransition:transitionContext \(transitionContext)")
        self.transitionContext = transitionContext
        animator.animateTransition(using: transitionContext)
        let interruptibleAnimator = animator.interruptibleAnimator?(using: transitionContext)
        interruptibleAnimator?.addCompletion?() { (pos) in
            self.animator.animationEnded?(!transitionContext.transitionWasCancelled)
        }
        interruptibleAnimator?.pauseAnimation()
    }
    
    // MARK: - Private
    
    @objc private func onGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.presented?.dismissViewController()
        case .changed:
            guard let view = gesture.view else { return }
            let delta = gesture.translation(in: view)
            let percent = abs(delta.y / view.bounds.size.width)
            self.update(percent)
        case .ended:
            guard let view = gesture.view else { return }
            let delta = gesture.translation(in: view)
            let percent = abs(delta.y / view.bounds.size.width)
            if percent.isLess(than: 0.3) {
                cancel()
            } else {
                finish()
            }
            
        case .cancelled:
            cancel()
        case .failed:
            cancel()
        default:
            break
        }
    }
    
    private func getReletiveTranslationInTargetView(forGesture gesture: UIPanGestureRecognizer) -> CGFloat {
        guard let view = transitionContext?.view(forKey: .to) else {
            return 0.0
        }
        return gesture.translation(in: view).x / view.bounds.width
    }
    
    private class func isSupported(animator: UIViewControllerAnimatedTransitioning) -> Bool {
        let selector = #selector(UIViewControllerAnimatedTransitioning.interruptibleAnimator)
        return animator.responds(to: selector)
    }
    
    private func update(_ percentComplete: CGFloat) {
        print("update \(percentComplete) \(transitionContext)")
        guard let context = transitionContext else {
//            fatalError("startInteractiveTransition must be called before this method!")
            return
        }
        let clampedFraction = percentComplete.clamped(to: 0.0 ... 1.0)
        animator.interruptibleAnimator?(using: context).fractionComplete = clampedFraction
        context.updateInteractiveTransition(clampedFraction)
    }
    
    private func finish() {
        print("finish \(transitionContext)")
        guard let context = transitionContext else {
//            fatalError("startInteractiveTransition must be called before this method!")
            return
        }
        animator.interruptibleAnimator?(using: context).startAnimation()
        context.finishInteractiveTransition()
    }
    
    private func cancel() {
        print("cancel \(transitionContext)")
        guard let context = transitionContext else {
            fatalError("startInteractiveTransition must be called before this method!")
        }
        let interruptibleAnimator = animator.interruptibleAnimator?(using: context)
        interruptibleAnimator?.isReversed = true
        interruptibleAnimator?.startAnimation()
        context.cancelInteractiveTransition()
    }
}

