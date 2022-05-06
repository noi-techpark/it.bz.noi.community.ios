//
//  EventsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit
import Foundation
import Combine

// MARK: - EventsCoordinator

final class EventsCoordinator: BaseNavigationCoordinator {

    override var rootViewController: UIViewController {
        mainVC
    }
    
    private var mainVC: EventsMainViewController!
    private var eventsViewModel: EventsViewModel!
    private var navigationDelegate: EventsNavigationControllerDelegate!
    private lazy var eventFiltersViewModel = dependencyContainer
        .makeEventFiltersViewModel { [weak self] in
            self?.closeFilters()
        }
    private var subscriptions: Set<AnyCancellable> = []

    override func start(animated: Bool) {
        navigationDelegate = EventsNavigationControllerDelegate(
            navigationController: navigationController
        )
        navigationController.delegate = navigationDelegate
        let eventsViewModel = dependencyContainer.makeEventsViewModel { [weak self] in
            self?.goToFilters()
        }
        self.eventsViewModel = eventsViewModel
        mainVC = EventsMainViewController(viewModel: eventsViewModel)
        mainVC.didSelectHandler = { [weak self] collectionView, _, indexPath, event in
            self?.goToDetails(
                of: event,
                transitionCollectionView: collectionView,
                transitionIndexPath: indexPath
            )
        }
        mainVC.tabBarItem.title = .localized("events_top_tab")

        eventFiltersViewModel.$activeFilters
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned eventsViewModel] in
                eventsViewModel.activeFilters = $0
                eventsViewModel.refreshEvents()
            }
            .store(in: &subscriptions)

        eventsViewModel.$eventResults
            .map(\.?.count)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned eventFiltersViewModel] numberOfResults in
                guard let numberOfResults = numberOfResults
                else { return }

                eventFiltersViewModel.numberOfResults = numberOfResults
            })
            .store(in: &subscriptions)
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

    func goToFilters() {
        let filtersVC = dependencyContainer.makeEventFiltersViewController(
            viewModel: eventFiltersViewModel
        )
        navigationController.present(
            NavigationController(rootViewController: filtersVC),
            animated: true,
            completion: nil
        )
    }

    func closeFilters() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
