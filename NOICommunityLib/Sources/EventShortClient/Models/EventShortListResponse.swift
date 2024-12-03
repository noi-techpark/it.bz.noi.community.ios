// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventShortListResponse.swift
//  EventShortClient
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation

// MARK: - EventShortListResponse

public struct EventShortListResponse: Decodable, Equatable {

    public let totalResults: Int
    public let totalPages: Int
    public let currentPage: Int
    public let onlineResults: Int?
    public let resultId: String?
    public let seed: String?
    public let items: [EventShort]

	enum CodingKeys: CodingKey {
		case totalResults
		case totalPages
		case currentPage
		case onlineResults
		case resultId
		case seed
		case items
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.totalResults = try container.decode(Int.self, forKey: .totalResults)
		self.totalPages = try container.decode(Int.self, forKey: .totalPages)
		self.currentPage = try container.decode(Int.self, forKey: .currentPage)
		self.onlineResults = try container.decodeIfPresent(Int.self, forKey: .onlineResults)
		self.resultId = try container.decodeIfPresent(String.self, forKey: .resultId)
		self.seed = try container.decodeIfPresent(String.self, forKey: .seed)
		self.items = try container.decodeIfPresent([EventShort].self, forKey: .items) ?? []
	}

}
