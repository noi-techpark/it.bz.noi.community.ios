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
    @Published var error: Error!
    @Published var eventResults: [Event]!
    
    private var refreshEventsRequestCancellable: AnyCancellable?
    
    let eventShortClient: EventShortClient
    let maximumNumberOfEvents: Int
    let maximumNumberOfRelatedEvents: Int
    let language: Language?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var roomMapping: [String:String]!
    
    init(
        eventShortClient: EventShortClient,
        language: Language?,
        maximumNumberOfEvents: Int = EventsFeatureConstants.maximumNumberOfEvents,
        maximumNumberOfRelatedEvents: Int = EventsFeatureConstants.maximumNumberOfRelatedEvents
    ) {
        self.eventShortClient = eventShortClient
        self.language = language
        self.maximumNumberOfEvents = maximumNumberOfEvents
        self.maximumNumberOfRelatedEvents = maximumNumberOfRelatedEvents
    }
    
    func refreshEvents(dateIntervalFilter: DateIntervalFilter = .all) {
        let (startDate, endDate) = dateIntervalFilter.toStartEndDates()
        
        isLoading = true
        eventResults = nil
        
        let roomMappingPublisher: AnyPublisher<[String : String], Error>
        if let roomMapping = roomMapping {
            roomMappingPublisher = Just(roomMapping)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            roomMappingPublisher = eventShortClient.roomMapping(language)
        }
        let eventListPublisher = eventShortClient
            .list(EventShortListRequest(
                pageSize: maximumNumberOfEvents,
                startDate: startDate,
                endDate: endDate,
                eventLocation: .noi,
                onlyActive: true,
                removeNullValues: true
            ))
        
        refreshEventsRequestCancellable = roomMappingPublisher
            .zip(eventListPublisher)
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
                receiveValue: { [weak self] in
                    guard let self = self
                    else { return }
                    
                    let (roomMappingResponse, eventShortListResponse) = $0
                    self.roomMapping = roomMappingResponse
                    let allEventsShort = eventShortListResponse.items ?? []
                    self.eventResults = allEventsShort.map { eventShort in
                        Event(
                            from: eventShort,
                            roomMapping: roomMappingResponse
                        )
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

// MARK: - DateIntervalFilter Additions

private extension DateIntervalFilter {
    func toStartEndDates(
        using calendar: Calendar = .current
    ) -> (start: Date, end: Date?) {
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let endDate: Date?
        switch self {
        case .all:
            endDate = nil
        case .today:
            endDate = calendar.endOfDay(for: now)
        case .currentWeek:
            endDate = calendar.endOfDay(for: calendar.lastDayOfWeek(for: now))
        case .currentMonth:
            endDate = calendar.endOfDay(for: calendar.lastDayOfMonth(for: now))
        }
        return (startDate, endDate)
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
        
        var imageURL = (eventShort.imageGallery ?? [])
            .lazy
            .compactMap(\.imageUrl)
            .first
            .flatMap(URL.init(string:))
        // Get an image from a http url as https content
        // see https://github.com/noi-techpark/odh-docs/wiki/How-to-get-a-Image-from-a-http-url-as-https-content.
        if
            let nonOptImageURL = imageURL,
            case "http" = nonOptImageURL.scheme {
            var urlComponents = URLComponents(
                string: "https://images.opendatahub.bz.it/api/Image/GetImageByURL"
            )!
            urlComponents.queryItems = [URLQueryItem(
                name: "imageurl",
                value: nonOptImageURL.absoluteString
            )]
            imageURL = urlComponents.url!
        }
        
        let mapURL = eventShort.anchorVenueRoomMapping
            .flatMap { key in roomMapping[key] }
            .flatMap(URL.init(string:))
        
        self.init(
            id: eventShort.id ?? UUID().uuidString,
            title: title,
            startDate: eventShort.startDate,
            endDate: eventShort.endDate,
            location: eventShort.eventLocation,
            venue: eventShort.anchorVenue,
            imageURL: imageURL,
            description: description,
            organizer: !eventShort.display5.isNilOrEmpty ?
            eventShort.display5 :
                eventShort.companyName,
            technologyFields: eventShort.technologyFields ?? [],
            mapURL: mapURL,
            signupURL: eventShort.webAddress.flatMap(URL.init(string:))
        )
    }
}
