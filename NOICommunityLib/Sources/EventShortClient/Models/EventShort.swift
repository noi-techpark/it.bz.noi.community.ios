// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventShort.swift
//  EventShortClient
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation

// MARK: - EventShort

public struct EventShort: Decodable, Equatable {

    public let licenseInfo: LicenseInfo?
    public let id: String?
    public let source: String?
    public let eventLocation: EventLocation?
    public let eventId: Int?
    public let eventDescription: String?
    public let eventDescriptionDE: String?
    public let eventDescriptionIT: String?
    public let eventDescriptionEN: String?
    public let anchorVenue: String?
    public let anchorVenueShort: String?
    public let anchorVenueRoomMapping: String?
    public let changedOn: String?
    public let startDate: Date
    public let endDate: Date
    public let webAddress: String?
    public let display1: String?
    public let display2: String?
    public let display3: String?
    public let display4: String?
    public let display5: String?
    public let display6: String?
    public let display7: String?
    public let display8: String?
    public let display9: String?
    public let companyName: String?
    public let companyId: String?
    public let companyAddressLine1: String?
    public let companyAddressLine2: String?
    public let companyAddressLine3: String?
    public let companyPostalCode: String?
    public let companyCity: String?
    public let companyCountry: String?
    public let companyPhone: String?
    public let companyFax: String?
    public let companyMail: String?
    public let companyUrl: String?
    public let contactCode: String?
    public let contactFirstName: String?
    public let contactLastName: String?
    public let contactPhone: String?
    public let contactCell: String?
    public let contactFax: String?
    public let contactEmail: String?
    public let contactAddressLine1: String?
    public let contactAddressLine2: String?
    public let contactAddressLine3: String?
    public let contactPostalCode: String?
    public let contactCity: String?
    public let contactCountry: String?
    public let roomBooked: [RoomBooked?]?
    public let imageGallery: [ImageGallery?]?
    public let videoUrl: String?
    public let activeWeb: Bool?
    public let eventTextDE: String?
    public let eventTextIT: String?
    public let eventTextEN: String?
    public let technologyFields: [String?]?
    public let customTagging: [String?]?
    public let soldOut: Bool?
    public let eventDocument: [DocumentPDF]?
    public let externalOrganizer: Bool?
    public let shortname: String?
    public let gpsPoints: GpsInfo?
    public let publishedOn: [String?]?
}

// MARK: - Source

public struct Source: Hashable {
    public let rawValue: String

    public static let content = Self(rawValue: "Content")
    public static let ebms = Self(rawValue: "EBMS")
}

// MARK: - EventLocation

public struct EventLocation: Hashable {
    public let rawValue: String

    public static let noi = Self(rawValue: "NOI")
    public static let eurac = Self(rawValue: "EC")
    public static let other = Self(rawValue: "OUT")
}

extension EventLocation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(rawValue: try container.decode(String.self))
    }
}

// MARK: - LicenseInfo

public struct LicenseInfo: Decodable, Equatable {
    public let license: String?
    public let licenseHolder: String?
    public let author: String?
    public let closedData: Bool
}

// MARK: - RoomBooked

public struct RoomBooked: Decodable, Equatable {
    public let space: String?
    public let spaceDesc: String?
    public let spaceAbbrev: String?
    public let spaceType: String?
    public let subtitle: String?
    public let comment: String?
    public let startDate: Date
    public let endDate: Date
}

// MARK: - GpsInfo

public struct GpsInfo: Decodable, Equatable {
    public let gpsType: String?
    public let latitude: Double
    public let longitude: Double
    public let altitude: Double?
    public let altitudeUnitOfMeasure: String?

    enum CodingKeys: String, CodingKey {
        case gpsType = "Gpstype"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case altitude = "Altitude"
        case altitudeUnitOfMeasure = "AltitudeUnitofMeasure"
    }
}

// MARK: - DocumentPDF

public struct DocumentPDF: Decodable, Equatable {
    public let documentURL: String?
    public let language: String?
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
