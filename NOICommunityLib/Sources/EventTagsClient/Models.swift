// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Models.swift
//  EventTagsClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

// MARK: - EventTagListResponse

public struct EventTagListResponse: Codable, Hashable {

	public let totalResults: Int
	public let items: [Tag]

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		totalResults = try container.decode(Int.self, forKey: .totalResults)
		items = try container.decodeIfPresent([Tag].self, forKey: .items) ?? []
	}

	public init(
		totalResults: Int,
		items: [Tag]
	) {
		self.totalResults = totalResults
		self.items = items
	}
}

// MARK: - Tag

public struct Tag: Codable, Hashable {

	public typealias LocalizedMap<T: Codable> = [String:T]
	public typealias Id = String

	public static let customTagging = "customtagging"
	public static let technologyFields = "technologyfields"

	public let id: Id
	public let tagName: LocalizedMap<String>
	public let types: [String]

	// A tag can be tagged with more than one type (eg. "digital" has both
	// "technologyfields" and "customtagging"); only the first is used, so a
	// tag always maps to exactly one filter category.
	public var isCustomTagging: Bool {
		types.first == Self.customTagging
	}

	public var isTechnologyFields: Bool {
		types.first == Self.technologyFields
	}

	public init(from decoder: any Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try values.decode(Id.self, forKey: .id)
		self.tagName = try values.decodeIfPresent(LocalizedMap<String>.self, forKey: .tagName) ?? [:]
		self.types = try values.decodeIfPresent([String].self, forKey: .types) ?? []
	}

	public init(
		id: String,
		tagName: LocalizedMap<String>,
		types: [String]
	) {
		self.id = id
		self.tagName = tagName
		self.types = types
	}
}
