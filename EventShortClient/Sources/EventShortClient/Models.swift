//
//  Models.swift
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
    public let items: [EventShort]?
}

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
    public let roomBooked: [RoomBooked]?
    public let imageGallery: [ImageGallery]?
    public let videoUrl: String?
    public let activeWeb: Bool?
    public let eventTextDE: String?
    public let eventTextIT: String?
    public let eventTextEN: String?
    public let technologyFields: [String]?
    public let customTagging: [String]?
    public let soldOut: Bool?
    public let eventDocument: [DocumentPDF]?
    public let externalOrganizer: Bool?
    public let shortname: String?
    public let gpsPoints: GpsInfo?
    public let publishedOn: [String]?
}

// MARK: - EventShortListRequest

public struct EventShortListRequest {
    public let pageNumber: Int?
    public let pageSize: Int?
    public let startDate: Date?
    public let endDate: Date?
    public let source: Source?
    public let eventLocation: EventLocation?
    public let onlyActive: Bool?
    public let eventIds: [String]?
    public let webAddress: String?
    public let sortOrder: Order?
    public let seed: Int?
    public let language: String?
    public let langFilter: [String]?
    public let fields: [String]?
    public let lastChange: Date?
    public let searchFilter: String?
    public let rawFilter: String?
    public let rawSort: String?
    public let removeNullValues: Bool?

    public init(
        pageNumber: Int? = nil,
        pageSize: Int? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        source: Source? = nil,
        eventLocation: EventLocation? = nil,
        onlyActive: Bool? = nil,
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
        removeNullValues: Bool? = nil
    ) {
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.startDate = startDate
        self.endDate = endDate
        self.source = source
        self.eventLocation = eventLocation
        self.onlyActive = onlyActive
        self.eventIds = eventIds
        self.webAddress = webAddress
        self.sortOrder = sortOrder
        self.seed = seed
        self.language = language
        self.langFilter = langFilter
        self.fields = fields
        self.lastChange = lastChange
        self.searchFilter = searchFilter
        self.rawFilter = rawFilter
        self.rawSort = rawSort
        self.removeNullValues = removeNullValues

    }
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

// MARK: - Order

public struct Order: Hashable {
    public let rawValue: String

    public static let ascending = Self(rawValue: "ASC")
    public static let descending = Self(rawValue: "DESC")
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
    public let width: Int
    public let height: Int
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
