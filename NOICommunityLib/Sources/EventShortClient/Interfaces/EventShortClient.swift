// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventShortClient.swift
//  EventShortClient
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation

public protocol EventShortClient {

	func getEventShortList(
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
	) async throws -> EventShortListResponse

	func getRoomMapping(
		language: String?
	) async throws -> [String:String]

	func getEventShort(
		id: String,
		language: String?,
		optimizeDates: Bool?,
		fields: [String]?,
		removeNullValues: Bool?
	) async throws -> EventShort

}

public extension EventShortClient {

	func getEventShortList(
		pageNumber: Int? = nil,
		pageSize: Int? = nil,
		startDate: Date? = nil,
		endDate: Date? = nil,
		source: Source? = nil,
		eventLocation: EventLocation? = nil,
		publishedon: String? = nil,
		eventIds: [String]? = nil,
		webAddress: String? = nil,
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
		optimizeDates: Bool? = nil
	) async throws -> EventShortListResponse {
		try await getEventShortList(
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
	}

	func getRoomMapping(
		language: String? = nil
	) async throws -> [String:String] {
		try await getRoomMapping(language: language)
	}

	func getEventShort(
		id: String,
		language: String? = nil,
		optimizeDates: Bool? = nil,
		fields: [String]? = nil,
		removeNullValues: Bool? = nil
	) async throws -> EventShort {
		try await getEventShort(
			id: id,
			language: language,
			optimizeDates: optimizeDates,
			fields: fields,
			removeNullValues: removeNullValues
		)
	}

}
