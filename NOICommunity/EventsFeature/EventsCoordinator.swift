//
//  EventsCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation

final class EventsCoordinator: BaseCoordinator {

    private var mainVC: EventsMainViewController!
    private var eventsViewModel: EventsViewModel!

    override func start(animated: Bool) {
        eventsViewModel = dependencyContainer.makeEventsViewModel()
        mainVC = EventsMainViewController(viewModel: eventsViewModel)
        mainVC.didSelectHandler = { [weak self] _, event in
            self?.goToDetails(of: event)
        }
        mainVC.navigationItem.title = .localized("title_today")
        navigationController.viewControllers = [mainVC]
    }
}

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

    func goToDetails(of event: Event) {
        let detailVC = EventDetailsViewController(
            for: event,
               relatedEvents: eventsViewModel.relatedEvent(of: event)
        )
        detailVC.addToCalendarActionHandler = { [weak self] in
            self?.addEventToCalendar($0)
        }
        detailVC.locateActionHandler = { [weak self] in
            self?.locateEvent($0)
        }
        detailVC.didSelectRelatedEventHandler = { [weak self] _, selectedEvent in
            self?.goToDetails(of: selectedEvent)
        }
        detailVC.navigationItem.title = event.title
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(detailVC, animated: true)
    }
}
