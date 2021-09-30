//
//  EventsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - EventsCoordinator

final class EventsCoordinator: BaseCoordinator {

    private var mainVC: EventsMainViewController!
    private var eventsViewModel: EventsViewModel!

    private var transitionInfos: [TransitionInfo] = []

    override func start(animated: Bool) {
        navigationController.delegate = self
        eventsViewModel = dependencyContainer.makeEventsViewModel()
        mainVC = EventsMainViewController(viewModel: eventsViewModel)
        mainVC.didSelectHandler = { [weak self] collectionView, _, indexPath, event in
            self?.goToDetails(
                of: event,
                transitionCollectionView: collectionView,
                transitionIndexPath: indexPath
            )
        }
        mainVC.navigationItem.title = .localized("title_today")
        navigationController.viewControllers = [mainVC]
    }
}

// MARK: Private APIs

private extension EventsCoordinator {
    func addEventToCalendar(_ event: Event) {
        EventsCalendarManager.shared.presentCalendarModalToAddEvent(
            event: event.toCalendarEvent(),
            from: navigationController
        ) { [weak navigationController] result in
            guard case let .failure(error) = result
            else { return }

            if let calendarError = error as? CalendarError {
                navigationController?.showCalendarError(calendarError)
            } else {
                navigationController?.showError(error)
            }
        }
    }

    func locateEvent(_ event: Event) {
        let mapViewController = WebViewController()
        mapViewController.url = event.mapUrl ?? .map
        mapViewController.navigationItem.title = event.mapUrl != nil ?
        event.venue:
            .localized("title_generic_noi_techpark_map")
        navigationController.pushViewController(
            mapViewController,
            animated: true
        )
    }

    func goToDetails(
        of event: Event,
        transitionCollectionView: UICollectionView? = nil,
        transitionIndexPath: IndexPath? = nil
    ) {
        let transitionId = "event_\(event.id)"
        if
            let transitionCollectionView = transitionCollectionView,
            let transitionIndexPath = transitionIndexPath {
            transitionInfos.append(.init(
                id: transitionId,
                collectionView: transitionCollectionView,
                indexPath: transitionIndexPath,
                event: event))
        }

        let detailVC = EventDetailsViewController(
            for: event,
               relatedEvents: eventsViewModel.relatedEvent(of: event)
        )
        detailVC.cardView.transitionId = transitionId
        detailVC.addToCalendarActionHandler = { [weak self] in
            self?.addEventToCalendar($0)
        }
        detailVC.locateActionHandler = { [weak self] in
            self?.locateEvent($0)
        }
        detailVC.didSelectRelatedEventHandler = { [weak self] collectionView, _, indexPath, selectedEvent in
            self?.goToDetails(
                of: selectedEvent,
                transitionCollectionView: collectionView,
                transitionIndexPath: indexPath
            )
        }
        detailVC.navigationItem.title = event.title
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailVC, animated: true)
    }
}

// MARK: UINavigationControllerDelegate

extension EventsCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let transitionInfo = transitionInfos.last,
            let transitionCollectionView = transitionInfo.collectionView
        else { return nil }

        let transitionBackgroundColor: UIColor = .secondaryBackgroundColor
        switch operation {
        case .push:
            return SourcePresentAnimator(
                with: transitionCollectionView,
                for: transitionInfo.indexPath,
                id: transitionInfo.id,
                transitionBackgroundColor: transitionBackgroundColor
            ) { sourceView in
                var contentConfiguration = EventCardContentConfiguration.makeDetailedContentConfiguration(for: transitionInfo.event)
                let detailedEventCardView = contentConfiguration.makeContentView()
                if let imageURL = transitionInfo.event.imageURL {
                    KingfisherManager.shared.retrieveImage(with: imageURL) { [weak detailedEventCardView] result in
                        guard case let .success(imageInfo) = result
                        else { return }

                        contentConfiguration.image = imageInfo.image
                        detailedEventCardView?.configuration = contentConfiguration
                    }
                }
                return detailedEventCardView
            }
        case .pop:
            defer {
                transitionInfos.removeLast()
            }
            return SourceDismissAnimator(
                with: transitionCollectionView,
                for: transitionInfo.indexPath,
                id: transitionInfo.id,
                transitionBackgroundColor: transitionBackgroundColor
            ) { sourceView in
                var contentConfiguration = EventCardContentConfiguration.makeContentConfiguration(for: transitionInfo.event)
                let detailedEventCardView = contentConfiguration.makeContentView()
                if let imageURL = transitionInfo.event.imageURL {
                    KingfisherManager.shared.retrieveImage(with: imageURL) { [weak detailedEventCardView] result in
                        guard case let .success(imageInfo) = result
                        else { return }

                        contentConfiguration.image = imageInfo.image
                        detailedEventCardView?.configuration = contentConfiguration
                    }
                }
                return detailedEventCardView
            }
        default:
            return nil
        }
    }
}

// MARK: - TransitionInfo

private struct TransitionInfo {
    var id: String
    weak var collectionView: UICollectionView!
    var indexPath: IndexPath
    var event: Event
}
