//
//  EventsCoordinator.NavigationControllerDelegate.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 06/10/21.
//

import UIKit

// MARK: - EventsCoordinator.EventsNavigationControllerDelegate
extension EventsCoordinator {
    class EventsNavigationControllerDelegate: NavigationControllerDelegate {
        
        private weak var navigationController: UINavigationController!
        
        private var interactionController: UIPercentDrivenInteractiveTransition?
        
        private lazy var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
            let result = UIScreenEdgePanGestureRecognizer()
            result.edges = .left
            result.delegate = self
            result.addTarget(
                self,
                action: #selector(handleCustomTransition(_:))
            )
            return result
        }()
        
        private let transitionBackgroundColor: UIColor = .noiSecondaryBackgroundColor
        
        private var shouldCancel = false
        
        struct TransitionInfo {
            var id: String
            weak var collectionView: UICollectionView!
            var indexPath: IndexPath
            var event: Event
        }
        var transitionInfos: [TransitionInfo] = []
        
        init(navigationController: UINavigationController) {
            self.navigationController = navigationController
            super.init()
            
            navigationController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
            if let interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer {
                screenEdgePanGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
            }
        }
        
        @objc private func handleCustomTransition(_ recognizer: UIScreenEdgePanGestureRecognizer) {
            let view = navigationController.view!
            switch recognizer.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()
                navigationController.popViewController(animated: true)
            case .changed:
                guard let interactionController = interactionController
                else { return }
                
                let translation = recognizer.translation(in: view)
                let progress = max(0, min(1, translation.x / view.bounds.width))
                shouldCancel = progress.isLess(than: 0.3)
                interactionController.update(progress)
            case .ended, .cancelled:
                if shouldCancel {
                    interactionController?.cancel()
                } else {
                    interactionController?.finish()
                }
                interactionController = nil
            default:
                break
            }
        }
    }
}

// MARK: UINavigationControllerDelegate

extension EventsCoordinator.EventsNavigationControllerDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        navigationController.viewControllers.count > 1
    }
}


// MARK: UINavigationControllerDelegate

extension EventsCoordinator.EventsNavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = !(viewController is EventDetailsViewController)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            guard toVC is EventDetailsViewController
            else { return nil }
            
            guard let transitionInfo = transitionInfos.last
            else { return nil }
            
            return SourcePresentAnimator(
                with: transitionInfo.collectionView,
                for: transitionInfo.indexPath,
                id: transitionInfo.id,
                transitionBackgroundColor: transitionBackgroundColor
            ) { sourceView in
                var contentConfiguration = EventCardContentConfiguration
                    .makeDetailedContentConfiguration(for: transitionInfo.event)
                let sourceCell = sourceView as! UICollectionViewCell
                let sourceContentConfig = sourceCell.contentConfiguration as! EventCardContentConfiguration
                contentConfiguration.image = sourceContentConfig.image
                return contentConfiguration.makeContentView()
            }
        case .pop:
            guard fromVC is EventDetailsViewController
            else { return nil }
            
            guard let transitionInfo = transitionInfos.last
            else { return nil }
            
            let dismissAnimator = SourceDismissAnimator(
                with: transitionInfo.collectionView,
                for: transitionInfo.indexPath,
                id: transitionInfo.id,
                transitionBackgroundColor: transitionBackgroundColor
            ) { sourceView in
                var contentConfiguration = EventCardContentConfiguration
                    .makeContentConfiguration(for: transitionInfo.event)
                let sourceContentView = sourceView as! (UIView & UIContentView)
                let sourceContentConfig = sourceContentView.configuration as! EventCardContentConfiguration
                contentConfiguration.image = sourceContentConfig.image
                return contentConfiguration.makeContentView()
            }
            dismissAnimator.onAnimationEnded = { [weak self] transitionCompleted in
                if transitionCompleted {
                    self?.transitionInfos.removeLast()
                }
            }
            return dismissAnimator
        default:
            return nil
        }
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
