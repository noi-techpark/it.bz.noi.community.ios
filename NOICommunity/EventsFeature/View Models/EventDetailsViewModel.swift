// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventDetailsViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 03/12/24.
//

import Foundation
import Combine
import CoreUI
import EventClient

// MARK: - EventDetailsViewModel

final class EventDetailsViewModel: BasePageViewModel {

	let eventClient: EventClient
	let eventId: String

	@Published private(set) var isLoading = false
	@Published private(set) var error: Error!
	@Published private(set) var result: Event!

	private var fetchRequestCancellable: AnyCancellable?

	@available(*, unavailable)
	required public init() {
		fatalError("\(#function) not available")
	}

	init(
		eventClient: EventClient,
		eventId: String
	) {
		self.eventClient = eventClient
		self.eventId = eventId

		super.init()
	}

	init(
		eventClient: EventClient,
		event: Event
	) {
		self.eventClient = eventClient
		self.eventId = event.id
		self.result = event

		super.init()
	}

	override func onViewDidLoad() {
		super.onViewDidLoad()

		if result == nil {
			fetchEvent(eventId: eventId)
		}
	}

	func fetchEvent(eventId: String) {
		Task(priority: .userInitiated) { [weak self] in
			await self?.performFetchEvent(withId: eventId)
		}
	}

}

// MARK: Private APIs

private extension EventDetailsViewModel {

	func performFetchEvent(withId eventId: String) async {
		isLoading = true
		defer {
			isLoading = false
		}

		do {
			let remoteEvent = try await eventClient.getEvent(
				id: eventId,
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
				removeNullValues: true
			)

			let venues: [String:Venue]
			if let venueIds = remoteEvent.venueIds, !venueIds.isEmpty {
				let response = try await eventClient.getVenues(ids: venueIds)
				venues = Dictionary(
					uniqueKeysWithValues: response.items.compactMap { venue in
						venue.id.map { ($0, venue) }
					}
				)
			} else {
				venues = [:]
			}

			result = .init(
				from: remoteEvent,
				venues: venues
			)
		} catch {
			self.error = error
		}
	}

}
