// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Venue.swift
//  EventClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

// MARK: - Venue

public struct Venue: Decodable, Equatable {
	public let id: String?
	public let detail: [String:VenueDetail]?
	public let roomDetails: [RoomDetail]?
}

// MARK: - VenueDetail

public struct VenueDetail: Decodable, Equatable {
	public let title: String?
}

// MARK: - RoomDetail

public struct RoomDetail: Decodable, Equatable {
	public let id: String?
	public let shortname: String?
	public let mapping: RoomMapping?
}

// MARK: - RoomMapping

public struct RoomMapping: Decodable, Equatable {
	// Not yet populated for any room, verified live against the whole NOI
	// Techpark venue — the equivalent data still exists in the deprecated
	// /v1/EventShort/RoomMapping endpoint but hasn't been migrated here yet.
	// Wired up regardless so it starts working the moment it's populated.
	public let maps: RoomMappingMaps?
}

// MARK: - RoomMappingMaps

public struct RoomMappingMaps: Decodable, Equatable {
	public let roommapping: String?
}

// MARK: - VenueListResponse

public struct VenueListResponse: Decodable, Equatable {

	public let totalResults: Int
	public let totalPages: Int
	public let currentPage: Int
	// Full "call this URL for the next/previous page" links, not page numbers.
	public let previousPage: String?
	public let nextPage: String?
	public let seed: String?
	public let items: [Venue]

	enum CodingKeys: CodingKey {
		case totalResults
		case totalPages
		case currentPage
		case previousPage
		case nextPage
		case seed
		case items
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.totalResults = try container.decode(Int.self, forKey: .totalResults)
		self.totalPages = try container.decode(Int.self, forKey: .totalPages)
		self.currentPage = try container.decode(Int.self, forKey: .currentPage)
		self.previousPage = try container.decodeIfPresent(String.self, forKey: .previousPage)
		self.nextPage = try container.decodeIfPresent(String.self, forKey: .nextPage)
		self.seed = try container.decodeIfPresent(String.self, forKey: .seed)
		self.items = try container.decodeIfPresent([Venue].self, forKey: .items) ?? []
	}

}
