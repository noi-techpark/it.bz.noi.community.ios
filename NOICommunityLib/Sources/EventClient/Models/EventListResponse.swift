// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventListResponse.swift
//  EventClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

// MARK: - EventListResponse

public struct EventListResponse: Decodable, Equatable {

	public let totalResults: Int
	public let totalPages: Int
	public let currentPage: Int
	// Full "call this URL for the next/previous page" links, not page numbers.
	public let previousPage: String?
	public let nextPage: String?
	public let seed: String?
	public let items: [RemoteEvent]

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
		self.items = try container.decodeIfPresent([RemoteEvent].self, forKey: .items) ?? []
	}

}
