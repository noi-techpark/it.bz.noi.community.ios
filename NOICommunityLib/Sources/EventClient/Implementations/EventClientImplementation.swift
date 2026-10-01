// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventClientImplementation.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation
import Core

// MARK: - EventClientImplementation

public final class EventClientImplementation: EventClient {

	private let baseURL: URL

	private let transport: Transport

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

	public init(
		baseURL: URL,
		transport: Transport
	) {
		self.baseURL = baseURL
		self.transport = transport
			.checkingStatusCodes()
			.addingJSONHeaders()
	}

	public func getEventList(
		pageNumber: Int?,
		pageSize: Int?,
		beginDate: Date?,
		endDate: Date?,
		publishedon: String?,
		eventIds: [String]?,
		sortOrder: Order?,
		seed: Int?,
		language: String?,
		langFilter: [String]?,
		fields: [String]?,
		lastChange: Date?,
		searchFilter: String?,
		rawFilter: String?,
		rawSort: String?,
		removeNullValues: Bool?,
		optimizeDates: Bool?,
		denormalize: Bool?
	) async throws -> EventListResponse {
		let request = Endpoint
			.eventList(
				pageNumber: pageNumber,
				pageSize: pageSize,
				beginDate: beginDate,
				endDate: endDate,
				publishedon: publishedon,
				eventIds: eventIds,
				sortOrder: sortOrder,
				seed: seed,
				language: language,
				langFilter: langFilter,
				fields: fields,
				lastChange: lastChange,
				searchFilter: searchFilter,
				rawFilter: rawFilter,
				rawSort: rawSort,
				removeNullValues: removeNullValues,
				optimizeDates: optimizeDates,
				denormalize: denormalize
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(
			EventListResponse.self,
			from: data
		)
	}

	public func getVenues(
		ids: [String],
		language: String?
	) async throws -> VenueListResponse {
		let request = Endpoint
			.venues(ids: ids, language: language)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(VenueListResponse.self, from: data)
	}

	public func getEvent(
		id: String,
		language: String?,
		fields: [String]?,
		removeNullValues: Bool?
	) async throws -> RemoteEvent {
		let request = Endpoint
			.event(
				id: id,
				language: language,
				fields: fields,
				removeNullValues: removeNullValues
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(RemoteEvent.self, from: data)
	}

}
