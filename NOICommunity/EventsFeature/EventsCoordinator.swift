//
//  EventsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import UIKit

// MARK: - EventsCoordinator

final class EventsCoordinator: BaseCoordinator {

    private var mainVC: EventsMainViewController!
    private var eventsViewModel: EventsViewModel!
    private var navigationDelegate: EventsNavigationControllerDelegate!

    override func start(animated: Bool) {
        navigationDelegate = EventsNavigationControllerDelegate(
            navigationController: navigationController
        )
        navigationController.delegate = navigationDelegate
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
        let mapViewController = MapWebViewController()
        mapViewController.url = event.mapURL ?? .map
        mapViewController.navigationItem.title = event.mapURL != nil ?
        event.venue:
            .localized("title_generic_noi_techpark_map")
        navigationController.pushViewController(
            mapViewController,
            animated: true
        )
    }

    func signupEvent(_ event: Event) {
        UIApplication.shared.open(
            event.signupURL!,
            options: [:],
            completionHandler: nil
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
            let transitionInfo = EventsNavigationControllerDelegate.TransitionInfo(
                id: transitionId,
                collectionView: transitionCollectionView,
                indexPath: transitionIndexPath,
                event: event
            )
            navigationDelegate.transitionInfos.append(transitionInfo)
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
        detailVC.signupActionHandler = { [weak self] in
            self?.signupEvent($0)
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
