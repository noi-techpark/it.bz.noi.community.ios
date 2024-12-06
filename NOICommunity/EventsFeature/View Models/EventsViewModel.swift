// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventsViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation
import Combine
import CoreUI
import EventShortClient
import EventShortTypesClient

// MARK: - EventsViewModel

final class EventsViewModel: BasePageViewModel {

    @Published var isLoading = false
    @Published var error: Error!
    @Published var eventResults: [Event]!
    @Published var dateIntervalFilter: DateIntervalFilter = .all
    @Published var activeFilters: Set<EventsFilter> = []

	private var refreshCancellable: AnyCancellable?
    private var refreshEventsRequestCancellable: AnyCancellable?
    
    let eventShortClient: EventShortClient
    let language: Language?
    let maximumNumberOfEvents: Int
    let showFiltersHandler: () -> Void
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var roomMapping: [String:String]!

	@available(*, unavailable)
	required init() {
		fatalError("\(#function) not available")
	}

    init(
        eventShortClient: EventShortClient,
        language: Language?,
        maximumNumberOfEvents: Int = EventsFeatureConstants.maximumNumberOfEvents,
        showFiltersHandler: @escaping () -> Void
    ) {
        self.eventShortClient = eventShortClient
        self.language = language
        self.maximumNumberOfEvents = maximumNumberOfEvents
        self.showFiltersHandler = showFiltersHandler
    }
	
    func refreshEvents() {
		Task(priority: .userInitiated) { [weak self] in
			await self?.performRefreshEvents()
		}
    }

    func showFilters() {
        showFiltersHandler()
    }

	override func configureBindings() {
		super.configureBindings()
		refreshCancellable = NotificationCenter
			.default
			.publisher(for: refreshEventsListNotification)
			.sink { [weak self] _ in
				self?.refreshEvents()
			}
	}

}

// MARK: Private APIs

private extension EventsViewModel {

	func performRefreshEvents() async {
		eventResults = nil

		isLoading = true
		defer {
			isLoading = false
		}

		do {
			roomMapping = if let availableRoomMapping = roomMapping {
				availableRoomMapping
			} else {
				try await eventShortClient.getRoomMapping(language: language?.rawValue)
			}

			let (startDate, endDate) = dateIntervalFilter.toStartEndDates()
			let response = try await eventShortClient.getEventShortList(
				pageSize: maximumNumberOfEvents,
				startDate: startDate,
				endDate: endDate,
				eventLocation: .noi,
				publishedon: "noi-communityapp",
				fields: [
					"AnchorVenue",
					"AnchorVenueRoomMapping",
					"CompanyName",
					"Display5",
					"EndDate",
					"EventDescriptionDE",
					"EventDescriptionEN",
					"EventDescriptionIT",
					"EventLocation",
					"EventTextDE",
					"EventTextEN",
					"EventTextIT",
					"Id",
					"ImageGallery",
					"StartDate",
					"WebAddress"
				],
				rawFilter: activeFilters.toQuery(),
				removeNullValues: true,
				optimizeDates: true
			)
			eventResults = response
				.items
				.map { eventShort in
					Event(
						from: eventShort,
						roomMapping: roomMapping
					)
				}
		} catch {
			self.error = error
		}
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

extension Event {

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
            .compactMap { $0?.imageUrl }
            .first
            .flatMap(URL.init(string:))
        // Get an image from a http url as https content
        // see https://github.com/noi-techpark/odh-docs/wiki/How-to-get-a-Image-from-a-http-url-as-https-content.
        if
            let nonOptImageURL = imageURL,
            case "http" = nonOptImageURL.scheme {
            var urlComponents = URLComponents(
                string: "https://images.opendatahub.com/api/Image/GetImageByURL"
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
            technologyFields: eventShort.technologyFields?.compactMap { $0 } ?? [],
            mapURL: mapURL,
            signupURL: eventShort.webAddress.flatMap(URL.init(string:))
        )
    }
}

// MARK: Query Helper

private extension Collection where Element == EventsFilter {

    func toQuery() -> String? {
        let filterToQuery: (EventsFilter) -> String = {
            // Eg. in(CustomTagging.[],"NOI Community")
            // Eg. in(TechnologyFields.[],"Alpine")
            #"in(\#($0.type.rawValue).[],"\#($0.key)")"#
        }

        let queryComponentsToQuery: ([String], String) -> String = { components, logicOperator in
            let components = components.filter { !$0.isEmpty }
            if components.isEmpty {
                return ""
            } else if components.count == 1 {
                return components.first!
            } else {
                return logicOperator + "(" + components.joined(separator: ",") + ")"
            }
        }

        let customTaggingQueryComponents = self
            .filter { $0.type == .customTagging }
            .map(filterToQuery)
        let customTaggingQuery = queryComponentsToQuery(
            customTaggingQueryComponents,
            "or"
        )

        let technologyFieldsQueryComponents = self
            .filter { $0.type == .technologyFields }
            .map(filterToQuery)
        let technologyFieldsQuery = queryComponentsToQuery(
            technologyFieldsQueryComponents,
            "or"
        )

        let result = queryComponentsToQuery(
            [customTaggingQuery, technologyFieldsQuery],
            "and"
        )
        guard !result.isEmpty
        else { return nil }

        return result
    }

}
