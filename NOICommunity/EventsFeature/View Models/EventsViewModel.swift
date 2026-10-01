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
import EventClient
import EventTagsClient

// MARK: - EventsViewModel

final class EventsViewModel: BasePageViewModel {

    @Published var isLoading = false
    @Published var error: Error!
    @Published var eventResults: [Event]!
    @Published var dateIntervalFilter: DateIntervalFilter = .all
    @Published var activeFilters: Set<Tag> = []

	private var refreshCancellable: AnyCancellable?
    private var refreshEventsRequestCancellable: AnyCancellable?

    let eventClient: EventClient
    let language: Language?
    let maximumNumberOfEvents: Int
    let showFiltersHandler: () -> Void

    private var subscriptions: Set<AnyCancellable> = []

	@available(*, unavailable)
	required init() {
		fatalError("\(#function) not available")
	}

    init(
        eventClient: EventClient,
        language: Language?,
        maximumNumberOfEvents: Int = EventsFeatureConstants.maximumNumberOfEvents,
        showFiltersHandler: @escaping () -> Void
    ) {
        self.eventClient = eventClient
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
			let (startDate, endDate) = dateIntervalFilter.toStartEndDates()
			let response = try await eventClient.getEventList(
				pageSize: maximumNumberOfEvents,
				beginDate: startDate,
				endDate: endDate,
				publishedon: "noi-communityapp",
				fields: [
					"DateBegin",
					"DateEnd",
					"Detail",
					"EventDate",
					"EventUrls",
					"Id",
					"ImageGallery",
					"OrganizerInfos",
					"VenueIds"
				],
				rawFilter: activeFilters.toQuery(),
				rawSort: "DateBegin",
				removeNullValues: true,
				optimizeDates: true,
				// An event can have several occurrences (different dates
				// and/or rooms). Denormalizing turns each occurrence into
				// its own list item — with DateBegin/DateEnd and EventDate
				// rewritten to that specific occurrence — so the room shown
				// always matches the date shown, at the cost of the same
				// underlying event potentially appearing more than once.
				denormalize: true
			)

			let venues = try await fetchVenues(
				for: response.items
			)

			eventResults = response
				.items
				.map { remoteEvent in
					Event(
						from: remoteEvent,
						venues: venues
					)
				}
		} catch {
			self.error = error
		}
	}

	func fetchVenues(
		for remoteEvents: [RemoteEvent]
	) async throws -> [String:Venue] {
		let venueIds = Set(remoteEvents.flatMap { $0.venueIds ?? [] })

		guard !venueIds.isEmpty
		else { return [:] }

		let response = try await eventClient.getVenues(
			ids: Array(venueIds),
			language: language?.rawValue
		)
		return Dictionary(
			uniqueKeysWithValues: response.items.compactMap { venue in
				venue.id.map { ($0, venue) }
			}
		)
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

// MARK: - RemoteEvent Additions

private extension RemoteEvent {

    var localizedTitles: [String:String] {
        (detail ?? [:]).compactMapValues { $0.title }
    }

    var localizedTexts: [String:String] {
        (detail ?? [:]).compactMapValues { $0.baseText }
    }

    var localizedOrganizerCompanyNames: [String:String] {
        (organizerInfos ?? [:]).compactMapValues { $0.companyName }
    }
}

// MARK: - Venue Additions

private extension Venue {

    var localizedTitles: [String:String] {
        (detail ?? [:]).compactMapValues { $0.title }
    }
}

// MARK: - Event Additions

/// Prefers the device's preferred language, but falls back to whatever
/// language the API did return rather than nil — the API doesn't always
/// localize every field (eg. organizer names) into every language.
private func localizedValueOrFirst(from dict: [String:String]) -> String? {
    localizedValue(from: dict) ?? dict.values.first
}

extension Event {

    init(
        from remoteEvent: RemoteEvent,
        venues: [String:Venue]
    ) {
        let title = localizedValueOrFirst(from: remoteEvent.localizedTitles)
        let description = localizedValueOrFirst(from: remoteEvent.localizedTexts)

        var imageURL = (remoteEvent.imageGallery ?? [])
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

        let matchingVenue = remoteEvent.venueIds?
            .lazy
            .compactMap { venues[$0] }
            .first

        // VenueIds only identifies the building (eg. "NOI Techpark"); the
        // specific room (eg. "NOISE", "Seminar 3") lives under
        // EventDate.VenueRoomDetailsIds and must be resolved against the
        // venue's own RoomDetails.
        let matchingRoom = remoteEvent.eventDate?
            .first?
            .venueRoomDetailsIds?
            .first
            .flatMap { roomId in matchingVenue?.roomDetails?.first { $0.id == roomId } }

        // Fall back to the building name if there's no room-specific match.
        let roomName = matchingRoom?.shortname.flatMap { $0.isEmpty ? nil : $0 }
        let venue = roomName
            ?? matchingVenue.flatMap { localizedValueOrFirst(from: $0.localizedTitles) }

        // Not populated for any room yet (verified live) — starts resolving
        // to a real per-room map link automatically once the backend
        // migrates this data from the deprecated RoomMapping endpoint.
        let mapURL = matchingRoom?.mapping?.maps?.roommapping
            .flatMap { $0.isEmpty ? nil : $0 }
            .flatMap(URL.init(string:))

        let signupURL = remoteEvent.eventUrls?
            .first { $0.type == "default" }?
            .url
            .flatMap { localizedValueOrFirst(from: $0) }
            .flatMap(URL.init(string:))

        self.init(
            id: remoteEvent.id ?? UUID().uuidString,
            title: title,
            startDate: remoteEvent.dateBegin,
            endDate: remoteEvent.dateEnd,
            venue: venue,
            imageURL: imageURL,
            description: description,
            organizer: localizedValueOrFirst(from: remoteEvent.localizedOrganizerCompanyNames),
            mapURL: mapURL,
            signupURL: signupURL
        )
    }
}

// MARK: Query Helper

private extension Collection where Element == Tag {

    func toQuery() -> String {
        let filterToQuery: (Tag) -> String = {
            // Eg. in(TagIds.[],"digital")
            #"in(TagIds.[],"\#($0.id)")"#
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
            .filter { $0.isCustomTagging }
            .map(filterToQuery)
        let customTaggingQuery = queryComponentsToQuery(
            customTaggingQueryComponents,
            "or"
        )

        let technologyFieldsQueryComponents = self
            .filter { $0.isTechnologyFields }
            .map(filterToQuery)
        let technologyFieldsQuery = queryComponentsToQuery(
            technologyFieldsQueryComponents,
            "or"
        )

        // NOI Techpark location, always required: location filtering has no
        // dedicated query parameter anymore, it is just another tag.
        let locationQuery = #"in(TagIds.[],"noi")"#

        return queryComponentsToQuery(
            [locationQuery, customTaggingQuery, technologyFieldsQuery],
            "and"
        )
    }

}
