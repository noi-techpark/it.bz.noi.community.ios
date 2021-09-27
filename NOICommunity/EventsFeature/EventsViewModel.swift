//
//  EventsViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation
import Combine
import EventShortClient

// MARK: - EventsViewModel

class EventsViewModel {

    @Published var isLoading = false
    @Published var isEmpty = false
    @Published var error: Error!
    @Published var eventResults: [Event] = []
    @Published var roomMapping: [String:String] = [:]

    var eventShortListRequestCancellable: AnyCancellable?
    var eventShortRoomMappingRequestCancellable: AnyCancellable?

    let eventShortClient: EventShortClient
    let maximumNumberOfEvents: Int
    let maximumNumberOfRelatedEvents: Int

    private var subscriptions: Set<AnyCancellable> = []
    private var responseResults: [EventShort] = []

    init(
        eventShortClient: EventShortClient,
        maximumNumberOfEvents: Int = EventsFeatureConstants.maximumNumberOfEvents,
        maximumNumberOfRelatedEvents: Int = EventsFeatureConstants.maximumNumberOfRelatedEvents
    ) {
        self.eventShortClient = eventShortClient
        self.maximumNumberOfEvents = maximumNumberOfEvents
        self.maximumNumberOfRelatedEvents = maximumNumberOfRelatedEvents

        refreshRoomMapping()
    }

    func refreshEvents(dateIntervalFilter: DateIntervalFilter = .all) {
        isLoading = true
        isEmpty = false
        eventResults = []

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let endDate: Date?
        switch dateIntervalFilter {
        case .all:
            endDate = nil
        case .today:
            endDate = calendar.endOfDay(for: now)
        case .currentWeek:
            endDate = calendar.endOfDay(for: calendar.lastDayOfWeek(for: now))
        case .currentMonth:
            endDate = calendar.endOfDay(for: calendar.lastDayOfMonth(for: now))
        }
        eventShortListRequestCancellable = eventShortClient
            .list(EventShortListRequest(
                pageSize: maximumNumberOfEvents,
                startDate: startDate,
                endDate: endDate,
                eventLocation: .noi,
                onlyActive: true,
                removeNullValues: true
            ))
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self
                    else { return }

                    let allEventsShort = response.items ?? []
                    self.isEmpty = allEventsShort.isEmpty
                    self.responseResults = allEventsShort
                    self.eventResults = allEventsShort.map { eventShort in
                        Event(from: eventShort, roomMapping: self.roomMapping)
                    }
                })
    }

    func relatedEvent(of event: Event) -> [Event] {
        let slice = eventResults
            .lazy
            .filter { candidateEvent in
                guard candidateEvent.id != event.id
                else { return false }

                for techField in event.technologyFields {
                    if candidateEvent.technologyFields.contains(techField) {
                        return true
                    }
                }
                return false
            }
            .prefix(maximumNumberOfRelatedEvents)
        return Array(slice)
    }
}

// MARK: Private APIs

private extension EventsViewModel {
    func refreshRoomMapping() {
        isLoading = true
        roomMapping = [:]

        eventShortRoomMappingRequestCancellable = eventShortClient
            .roomMapping()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false

                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] response in
                    self?.roomMapping = response
                })
    }
}

// MARK: - EventShort Additions
private extension EventShort {
    var localizedEventDescriptions: [String:String] {
        Dictionary(uniqueKeysWithValues: [
            eventDescriptionIT.map { ("it", $0) },
            eventDescriptionEN.map { ("en", $0) },
            eventDescriptionDE.map { ("de", $0) }
        ].compactMap { $0 })
    }

    var localizedEventTexts: [String:String] {
        Dictionary(uniqueKeysWithValues: [
            eventTextIT.map { ("it", $0) },
            eventTextEN.map { ("en", $0) },
            eventTextDE.map { ("de", $0) }
        ].compactMap { $0 })
    }
}

// MARK: - Event Additions

private extension Event {
    init(
        from eventShort: EventShort,
        roomMapping: [String:String]
    ) {
        let title = localizedValue(
            from: eventShort.localizedEventDescriptions,
            defaultValue: eventShort.eventDescription
        )
        let description = localizedValue(
            from: eventShort.localizedEventTexts,
            defaultValue: eventShort.eventTextEN
        )
        self.init(
            id: eventShort.id ?? UUID().uuidString,
            title: title,
            startDate: eventShort.startDate,
            endDate: eventShort.endDate,
            location: eventShort.eventLocation,
            venue: eventShort.anchorVenue,
            imageURL: (eventShort.imageGallery ?? [])
                .lazy
                .compactMap(\.imageUrl)
                .first
                .flatMap(URL.init(string:)),
            description: description,
            organizer: !eventShort.display5.isNilOrEmpty ?
            eventShort.display5 :
                eventShort.companyName,
            technologyFields: eventShort.technologyFields ?? [],
            mapUrl: eventShort.anchorVenueRoomMapping
                .flatMap { key in roomMapping[key] }
                .flatMap(URL.init(string:))
        )
    }
}
