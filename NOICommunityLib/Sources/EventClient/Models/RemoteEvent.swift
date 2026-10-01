// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Event.swift
//  EventClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

// MARK: - RemoteEvent

public struct RemoteEvent: Decodable, Equatable {

	public let id: String?
	public let source: String?
	public let dateBegin: Date
	public let dateEnd: Date
	public let licenseInfo: LicenseInfo?
	public let imageGallery: [ImageGallery?]?
	public let detail: [String:EventDetail]?
	public let organizerInfos: [String:OrganizerInfo]?
	public let eventUrls: [EventUrl]?
	public let venueIds: [String]?
	public let eventDate: [EventDate]?
	public let publishedOn: [String?]?
}

// MARK: - EventDate

public struct EventDate: Decodable, Equatable {
	// The specific room(s) this occurrence takes place in, as ids into the
	// venue's RoomDetails (see Venue.swift) — not to be confused with
	// VenueIds, which only identifies the building.
	public let venueRoomDetailsIds: [String]?
}

// MARK: - EventDetail

public struct EventDetail: Decodable, Equatable {
	public let title: String?
	public let baseText: String?
	public let language: String?
}

// MARK: - OrganizerInfo

public struct OrganizerInfo: Decodable, Equatable {
	public let companyName: String?
}

// MARK: - EventUrl

public struct EventUrl: Decodable, Equatable {
	public let url: [String:String]?
	public let type: String?
	public let active: Bool?
}

// MARK: - LicenseInfo

public struct LicenseInfo: Decodable, Equatable {
	public let license: String?
	public let licenseHolder: String?
	public let author: String?
	public let closedData: Bool
}

// MARK: - ImageGallery

public struct ImageGallery: Decodable, Equatable {
	public let imageName: String?
	public let imageUrl: String?
	public let width: Int?
	public let height: Int?
	public let imageSource: String?
	public let imageTitle: [String:String]?
	public let imageDesc: [String:String]?
	public let imageAltText: [String:String]?
	public let isInGallery: Bool?
	public let listPosition: Int?
	public let validFrom: String? // TODO: must be Date
	public let validTo: String? // TODO: must be Date
	public let copyRight: String?
	public let license: String?
	public let licenseHolder: String?
	public let imageTags: [String]?
}

// MARK: - Language

public enum Language: String {
	case en = "en"
	case it = "it"
	case de = "de"
}
