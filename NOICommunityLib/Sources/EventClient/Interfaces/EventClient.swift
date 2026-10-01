// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventClient.swift
//  EventClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

public protocol EventClient {

	func getEventList(
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
	) async throws -> EventListResponse

	func getVenues(
		ids: [String],
		language: String?
	) async throws -> VenueListResponse

	func getEvent(
		id: String,
		language: String?,
		fields: [String]?,
		removeNullValues: Bool?
	) async throws -> RemoteEvent

}

public extension EventClient {

	func getEventList(
		pageNumber: Int? = nil,
		pageSize: Int? = nil,
		beginDate: Date? = nil,
		endDate: Date? = nil,
		publishedon: String? = nil,
		eventIds: [String]? = nil,
		sortOrder: Order? = nil,
		seed: Int? = nil,
		language: String? = nil,
		langFilter: [String]? = nil,
		fields: [String]? = nil,
		lastChange: Date? = nil,
		searchFilter: String? = nil,
		rawFilter: String? = nil,
		rawSort: String? = nil,
		removeNullValues: Bool? = nil,
		optimizeDates: Bool? = nil,
		denormalize: Bool? = nil
	) async throws -> EventListResponse {
		try await getEventList(
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
	}

	func getVenues(
		ids: [String],
		language: String? = nil
	) async throws -> VenueListResponse {
		try await getVenues(ids: ids, language: language)
	}

	func getEvent(
		id: String,
		language: String? = nil,
		fields: [String]? = nil,
		removeNullValues: Bool? = nil
	) async throws -> RemoteEvent {
		try await getEvent(
			id: id,
			language: language,
			fields: fields,
			removeNullValues: removeNullValues
		)
	}

}
