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
import EventShortClient

// MARK: - EventDetailsViewModel

final class EventDetailsViewModel: BasePageViewModel {

	let eventShortClient: EventShortClient
	let eventId: String

	@Published private(set) var isLoading = false
	@Published private(set) var error: Error!
	@Published private(set) var result: Event!

	private var roomMapping: [String:String]!

	private var fetchRequestCancellable: AnyCancellable?

	@available(*, unavailable)
	required public init() {
		fatalError("\(#function) not available")
	}

	init(
		eventShortClient: EventShortClient,
		eventId: String
	) {
		self.eventShortClient = eventShortClient
		self.eventId = eventId

		super.init()
	}

	init(
		eventShortClient: EventShortClient,
		event: Event
	) {
		self.eventShortClient = eventShortClient
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
			roomMapping = if let availableRoomMapping = roomMapping {
				availableRoomMapping
			} else {
				try await eventShortClient.getRoomMapping()
			}

			let eventShort = try await eventShortClient.getEventShort(
				id: eventId,
				optimizeDates: true,
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
				removeNullValues: true
			)
			result = .init(
				from: eventShort,
				roomMapping: roomMapping
			)
		} catch {
			self.error = error
		}
	}

}
