// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventShortClientImplementation.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/12/24.
//

import Foundation
import Core

// MARK: - EventShortClientImplementation

public final class EventShortClientImplementation: EventShortClient {

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

	public func getEventShortList(
		pageNumber: Int?,
		pageSize: Int?,
		startDate: Date?,
		endDate: Date?,
		source: Source?,
		eventLocation: EventLocation?,
		publishedon: String?,
		eventIds: [String]?,
		webAddress: String?,
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
		optimizeDates: Bool?
	) async throws -> EventShortListResponse {
		let request = Endpoint
			.eventShortList(
				pageNumber: pageNumber,
				pageSize: pageSize,
				startDate: startDate,
				endDate: endDate,
				source: source,
				eventLocation: eventLocation,
				publishedon: publishedon,
				eventIds: eventIds,
				webAddress: webAddress,
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
				optimizeDates: optimizeDates
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(
			EventShortListResponse.self,
			from: data
		)
	}

	public func getRoomMapping(
		language: String?
	) async throws -> [String:String] {
		let request = Endpoint
			.roomMapping(language: language)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode([String:String].self, from: data)
	}

	public func getEventShort(
		id: String,
		language: String?,
		optimizeDates: Bool?,
		fields: [String]?,
		removeNullValues: Bool?
	) async throws -> EventShort {
		let request = Endpoint
			.eventShort(
				id: id,
				language: language,
				optimizeDates: optimizeDates,
				fields: fields,
				removeNullValues: removeNullValues
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(EventShort.self, from: data)
	}

}
