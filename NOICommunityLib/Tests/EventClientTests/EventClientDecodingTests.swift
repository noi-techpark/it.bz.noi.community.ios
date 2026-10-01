// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventClientDecodingTests.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import XCTest

@testable import EventClient

final class EventClientDecodingTests: XCTestCase {

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()

		jsonDecoder.dateDecodingStrategy = .custom { decoder in
			let container = try decoder.singleValueContainer()
			let dateStr = try container.decode(String.self)

			let dateFormatter = DateFormatter()
			dateFormatter.calendar = Calendar(identifier: .iso8601)
			dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")
			dateFormatter.locale = Locale(identifier: "en_US_POSIX")

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
			if let date = dateFormatter.date(from: dateStr) {
				return date
			}

			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Cannot decode date string \(dateStr)"
			)
		}

		jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
		return jsonDecoder
	}()

	private func fixtureData(_ name: String) throws -> Data {
		let url = try XCTUnwrap(
			Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
		)
		return try Data(contentsOf: url)
	}

	func testDecodeSingleEvent() throws {
		let data = try fixtureData("event")
		let event = try jsonDecoder.decode(RemoteEvent.self, from: data)

		XCTAssertEqual(event.id, "urn:event:noi:29f3ca8d-5ec7-462f-ab9d-7b00abefa738")
		XCTAssertEqual(event.detail?["en"]?.title, "Scratch Stories with AI | 6-8 years")
		XCTAssertEqual(event.organizerInfos?["en"]?.companyName, "NOI")
		XCTAssertEqual(event.venueIds, ["urn:venue:noi:6b3f0a14-3c5b-5d09-81f3-3ebe5b7885ea"])
		XCTAssertEqual(
			event.eventUrls?.first { $0.type == "default" }?.url?["en"],
			"https://registration.noi.bz.it/event/?id=MiniNOI_Science_Club_01062024_6-8_anni_930-12003585025325"
		)
		let imageUrl = event.imageGallery?.compactMap { $0 }.first?.imageUrl
		XCTAssertEqual(imageUrl, "https://tourism.images.opendatahub.com/api/Image/GetImage?imageurl=b0c9006c-27ce-407f-93f4-d456c3bbf778.jpg")

		// The specific room an event takes place in only lives under
		// EventDate.VenueRoomDetailsIds, not under the top-level VenueIds
		// (which only identifies the building) — this is what a Venue lookup
		// must resolve against RoomDetails to show a room name like "NOISE".
		XCTAssertEqual(
			event.eventDate?.first?.venueRoomDetailsIds,
			["urn:venueroomid:noi:5041c0f8-880d-5fb0-ac8d-62d4792d5c2f"]
		)
	}

	func testDecodeEventListResponse() throws {
		let data = try fixtureData("event_list")
		let response = try jsonDecoder.decode(EventListResponse.self, from: data)

		XCTAssertGreaterThan(response.totalResults, 0)
		XCTAssertFalse(response.items.isEmpty)
	}

	func testDecodeVenueListResponse() throws {
		let data = try fixtureData("venue_list")
		let response = try jsonDecoder.decode(VenueListResponse.self, from: data)

		XCTAssertEqual(response.totalResults, 1)
		let venue = try XCTUnwrap(response.items.first)
		XCTAssertEqual(venue.id, "urn:venue:noi:6b3f0a14-3c5b-5d09-81f3-3ebe5b7885ea")
		XCTAssertEqual(venue.detail?["en"]?.title, "NOI Techpark")

		let room = try XCTUnwrap(
			venue.roomDetails?.first { $0.id == "urn:venueroomid:noi:5041c0f8-880d-5fb0-ac8d-62d4792d5c2f" }
		)
		XCTAssertEqual(room.shortname, "NOISE")
		// Not populated for this room in the live API today — must decode
		// to nil rather than throw, so the "locate on map" button degrades
		// gracefully until the backend migrates this data.
		XCTAssertNil(room.mapping?.maps?.roommapping)

		let roomWithMapping = try XCTUnwrap(
			venue.roomDetails?.first { $0.id == "urn:venueroomid:noi:79179fbf-fef5-536c-b63f-eb7bf130522f" }
		)
		XCTAssertEqual(roomWithMapping.shortname, "Seminar 3")
		XCTAssertEqual(roomWithMapping.mapping?.maps?.roommapping, "https://maps.noi.bz.it/en/?shared=A1--1-17")
	}

}
