//
//  SourcePresentAnimator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 01/10/21.
//

import UIKit

class SourceDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let collectionView: UICollectionView
    private let indexPath: IndexPath
    private let transitionId: String
    private let transitionBackgroundColor: UIColor
    private let sourceViewPlaceholderMaker: (UIView) -> UIView?
    private let transitionDuration: TimeInterval

    private var animator: UIViewImplicitlyAnimating?

    private var isAnimating: Bool = false

    init(
        with collectionView: UICollectionView,
        for indexPath: IndexPath,
        id transitionId: String,
        transitionBackgroundColor: UIColor = .white,
        sourceViewPlaceholderMaker: @escaping (UIView) -> UIView? = {
            $0.snapshotView(afterScreenUpdates: true)
        },
        transitionDuration: TimeInterval = 0.30
    ) {
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.transitionId = transitionId
        self.transitionBackgroundColor = transitionBackgroundColor
        self.sourceViewPlaceholderMaker = sourceViewPlaceholderMaker
        self.transitionDuration = transitionDuration
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        transitionDuration
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        guard animator == nil
        else { return animator! }

        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let sourceView = fromVC.view.view(withTransitionId: transitionId),
            let toVC = transitionContext.viewController(forKey: .to),
            let sourcePlaceholderView = sourceViewPlaceholderMaker(sourceView),
            let targetView = collectionView.cellForItem(at: indexPath),
            let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return UIViewPropertyAnimator()
        }

        let initialFrame = sourceView.frame
        let standardFinalFrame = collectionView.convert(
            attributes.frame,
            to: toVC.view
        )
        let finalFrame: CGRect
        if let provider = toVC as? CurrentScrollOffsetProvider {
            var rect = standardFinalFrame
            rect.origin.x -= provider.currentScrollOffset.x
            finalFrame = rect
        } else {
            finalFrame = standardFinalFrame
        }

        let containerView = transitionContext.containerView
        containerView.backgroundColor = transitionBackgroundColor
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.addSubview(sourcePlaceholderView)
        sourcePlaceholderView.frame = initialFrame
        sourcePlaceholderView.layoutIfNeeded()

        toVC.view.alpha = 0
        fromVC.view.alpha = 1
        targetView.alpha = 0
        let animator = UIViewPropertyAnimator(
            duration: transitionDuration(using: transitionContext),
            curve: .easeOut
        ) {
            toVC.view.alpha = 1
            fromVC.view.alpha = 0
            sourcePlaceholderView.frame = finalFrame
        }

        animator.addCompletion { position in
            switch position {
            case .start:
                toVC.view.alpha = 0
                fromVC.view.alpha = 1
                targetView.alpha = 0
            case .end:
                toVC.view.alpha = 1
                fromVC.view.alpha = 0
                targetView.alpha = 1
            case .current: break
            @unknown default: break
            }
            sourcePlaceholderView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.isAnimating = false

        }
        self.animator = animator
        return animator
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        if case .inactive = animator.state {
            animator.startAnimation()
        }
    }
}
