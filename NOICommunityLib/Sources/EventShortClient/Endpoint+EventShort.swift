// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+EventShort.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/12/24.
//

import Foundation
import Core

// MARK: - Endpoint+EventShort

extension Endpoint {

	static func eventShortList(
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
	) -> Endpoint {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = Calendar(identifier: .iso8601)
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Rome")!
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

		return Self(path: "/v1/EventShort") {
			if let pageNumber {
				URLQueryItem(
					name: "pagenumber",
					value: "\(pageNumber)"
				)
			}

			if let pageSize {
				URLQueryItem(
					name: "pagesize",
					value: "\(pageSize)"
				)
			}

			if let startDate {
				URLQueryItem(
					name: "startdate",
					value: dateFormatter.string(from: startDate)
				)
			}

			if let endDate {
				URLQueryItem(
					name: "enddate",
					value: dateFormatter.string(from: endDate)
				)
			}

			if let source {
				URLQueryItem(
					name: "source",
					value: source.rawValue)
			}

			if let eventLocation {
				URLQueryItem(
					name: "eventlocation",
					value: eventLocation.rawValue)
			}

			if let publishedon {
				URLQueryItem(
					name: "publishedon",
					value: publishedon)
			}

			if let eventIds {
				URLQueryItem(
					name: "eventids",
					value: eventIds.joined(separator: ",")
				)
			}

			if let webAddress {
				URLQueryItem(
					name: "webaddress",
					value: webAddress
				)
			}

			if let sortOrder {
				URLQueryItem(
					name: "sortorder",
					value: sortOrder.rawValue
				)
			}

			if let seed {
				URLQueryItem(
					name: "seed",
					value: "\(seed)"
				)
			}

			if let language {
				URLQueryItem(
					name: "language",
					value: language)
			}

			if let langFilter {
				URLQueryItem(
					name: "langfilter",
					value: langFilter.joined(separator: ",")
				)
			}

			if let fields {
				URLQueryItem(
					name: "fields",
					value: fields.joined(separator: ",")
				)
			}

			if let lastChange {
				URLQueryItem(
					name: "lastchange",
					value: dateFormatter.string(from: lastChange)
				)
			}

			if let searchFilter {
				URLQueryItem(
					name: "searchfilter",
					value: searchFilter
				)
			}

			if let rawFilter {
				URLQueryItem(
					name: "rawfilter",
					value: rawFilter
				)
			}

			if let rawSort {
				URLQueryItem(
					name: "rawsort",
					value: rawSort
				)
			}

			if let removeNullValues {
				URLQueryItem(
					name: "removenullvalues",
					value: String(removeNullValues)
				)
			}

			if let optimizeDates {
				URLQueryItem(
					name: "optimizedates",
					value: String(optimizeDates)
				)
			}
		}
	}

	static func roomMapping(
		language: String? = nil
	) -> Endpoint {
		Self(path: "/v1/EventShort/RoomMapping") {
			if let language {
				URLQueryItem(
					name: "language",
					value: language
				)
			}
		}
	}

	static func eventShort(
		id: String,
		language: String? = nil,
		optimizeDates: Bool? = nil,
		fields: [String]? = nil,
		removeNullValues: Bool? = nil
	) -> Endpoint {
		Self(path: "/v1/EventShort/\(id)") {
			if let language {
				URLQueryItem(
					name: "language",
					value: language
				)
			}


			if let fields {
				URLQueryItem(
					name: "optimizedates",
					value: fields.joined(separator: ",")
				)
			}


			if let optimizeDates {
				URLQueryItem(
					name: "optimizedates",
					value: String(optimizeDates)
				)
			}


			if let removeNullValues {
				URLQueryItem(
					name: "removenullvalues",
					value: String(removeNullValues)
				)
			}
		}
	}

}
