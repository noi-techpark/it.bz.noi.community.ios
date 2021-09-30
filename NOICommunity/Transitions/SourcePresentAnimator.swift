//
//  SourcePresentAnimator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 01/10/21.
//

import UIKit

class SourcePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private weak var collectionView: UICollectionView?
    private let indexPath: IndexPath
    private let transitionId: String
    private let transitionBackgroundColor: UIColor
    private let sourceViewPlaceholderMaker: (UIView) -> UIView?
    private let transitionDuration: TimeInterval

    init(
        with collectionView: UICollectionView,
        for indexPath: IndexPath,
        id transitionId: String,
        transitionBackgroundColor: UIColor = .white,
        sourceViewPlaceholderMaker: @escaping (UIView) -> UIView? = {
            $0.snapshotView(afterScreenUpdates: true)
        },
        transitionDuration: TimeInterval = 0.75
    ) {
        self.collectionView = collectionView
        self.indexPath = indexPath
        self.transitionId = transitionId
        self.transitionBackgroundColor = transitionBackgroundColor
        self.sourceViewPlaceholderMaker = sourceViewPlaceholderMaker
        self.transitionDuration = transitionDuration
        super.init()
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let collectionView = collectionView,
            let sourceView = collectionView.cellForItem(at: indexPath),
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC: UIViewController = transitionContext.viewController(forKey: .to),
            let targetView = toVC.view.view(withTransitionId: transitionId),
            let sourcePlaceholderView = sourceViewPlaceholderMaker(sourceView),
            let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        else {
            return transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        let standardInitialFrame = collectionView.convert(
            attributes.frame,
            to: fromVC.view
        )
        let initialFrame: CGRect
        if let provider = fromVC as? CurrentScrollOffsetProvider {
            var rect = standardInitialFrame
            rect.origin.x -= provider.currentScrollOffset.x
            initialFrame = rect
        } else {
            initialFrame = standardInitialFrame
        }

        let containerView = transitionContext.containerView
        containerView.backgroundColor = transitionBackgroundColor
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        containerView.addSubview(sourcePlaceholderView)
        sourcePlaceholderView.frame = initialFrame

        toVC.view.layoutIfNeeded()

        toVC.view.alpha = 0
        sourceView.alpha = 0
        targetView.alpha = 0
        var finalFrame = targetView.frame
        finalFrame.origin.y = toVC.view.safeAreaInsets.top

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [UIView.AnimationOptions.transitionCrossDissolve],
            animations: {
                fromVC.view.alpha = 0
                toVC.view.alpha = 1

                sourcePlaceholderView.frame = finalFrame
            },
            completion: { completed in
                toVC.view.alpha = 1
                targetView.alpha = 1
                sourcePlaceholderView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
