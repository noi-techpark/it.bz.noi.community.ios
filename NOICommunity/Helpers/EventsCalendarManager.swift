//
//  EventsCalendarManager.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/2021.
//  Copyright © 2020 DIMENSION S.r.l. All rights reserved.
//

import EventKit
import EventKitUI
import UIKit

enum CalendarError: Error {
    case eventNotAddedToCalendar
    case calendarAccessDeniedOrRestricted
    case unknownAuthStatus(EKAuthorizationStatus)
}

extension CalendarError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .eventNotAddedToCalendar:
            return .localized("error_calendar_event_not_added")
        case .calendarAccessDeniedOrRestricted:
            return .localized("error_calendar_access_not_granted_or_restricted")
        case .unknownAuthStatus:
            return localizedDescription
        }
    }
}

protocol CalendarEvent {
    var title: String? { get }
    var startDate: Date? { get }
    var endDate: Date? { get }
    var location: String? { get }
    var notes: String? { get }
    var url: URL? { get }
}

extension CalendarEvent {
    var startDate: Date? { nil }
    var endDate: Date? { nil }
    var location: String? { nil }
    var notes: String? { nil }
    var url: URL? { nil }
}

class EventsCalendarManager: NSObject {
    typealias Callback = (Result<Void, Error>) -> Void

    fileprivate var eventStore: EKEventStore!

    static let shared = EventsCalendarManager()

    override init() {
        eventStore = EKEventStore()
    }

    // Show event kit ui to add event to calendar
    func presentCalendarModalToAddEvent(
        event: CalendarEvent,
        from viewController: UIViewController,
        completion: @escaping Callback
    ) {
        let presentationBlock: () -> Void = { [weak self] in
            self?.presentEventEventEditViewController(
                from: viewController,
                for: event
            )
        }
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            presentationBlock()
            completion(.success(()))
        case .notDetermined:
            // Auth is not determined
            // We should request access to the calendar
            requestAccess { accessGranted, _ in
                if accessGranted {
                    DispatchQueue.main.async(execute: presentationBlock)
                    completion(.success(()))
                } else {
                    // Auth denied, we should display a popup
                    completion(.failure(CalendarError.calendarAccessDeniedOrRestricted))
                }
            }
        case .denied,
                .restricted:
            // Auth denied or restricted, we should display a popup
            completion(.failure(CalendarError.calendarAccessDeniedOrRestricted))
        @unknown default:
            completion(.failure(CalendarError.unknownAuthStatus(authStatus)))
        }
    }
}

// MARK: EKEventEditViewDelegate

extension EventsCalendarManager: EKEventEditViewDelegate {
    func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith _: EKEventEditViewAction
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: Private APIs

private extension EventsCalendarManager {
    func requestAccess(
        completion: @escaping EKEventStoreRequestAccessCompletionHandler
    ) {
        eventStore.requestAccess(to: .event) { accessGranted, error in
            completion(accessGranted, error)
        }
    }

    func getAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func makeEvent(event: CalendarEvent) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = event.title
        let startDate = event.startDate ?? Date()
        newEvent.startDate = startDate
        if let endDate = event.endDate {
            newEvent.endDate = endDate
        } else {
            newEvent.endDate = Calendar.current.date(
                byAdding: .hour,
                value: 1,
                to: startDate
            )
        }
        newEvent.location = event.location
        newEvent.notes = event.notes
        newEvent.url = event.url
        return newEvent
    }

    func presentEventEventEditViewController(
        from viewController: UIViewController,
        for event: CalendarEvent
    ) {
        let event = makeEvent(event: event)
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        viewController.present(eventModalVC, animated: true, completion: nil)
    }
}
