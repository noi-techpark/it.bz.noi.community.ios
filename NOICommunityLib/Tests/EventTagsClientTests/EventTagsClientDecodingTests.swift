// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventTagsClientDecodingTests.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import XCTest

@testable import EventTagsClient

final class EventTagsClientDecodingTests: XCTestCase {

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
		return jsonDecoder
	}()

	func testDecodeEventTagListResponse() throws {
		let url = try XCTUnwrap(
			Bundle.module.url(forResource: "event_tag_list", withExtension: "json", subdirectory: "Fixtures")
		)
		let data = try Data(contentsOf: url)
		let response = try jsonDecoder.decode(EventTagListResponse.self, from: data)

		XCTAssertEqual(response.totalResults, 2)
		XCTAssertEqual(response.items.count, 2)

		let digital = try XCTUnwrap(response.items.first { $0.id == "digital" })
		XCTAssertEqual(digital.tagName["en"], "Digital")
		// "digital" is tagged with both categories, confirmed live against the
		// real /v1/Tag endpoint ("technologyfields" listed first) — only the
		// first type is used, so it maps to exactly one filter section.
		XCTAssertFalse(digital.isCustomTagging)
		XCTAssertTrue(digital.isTechnologyFields)

		let artsculture = try XCTUnwrap(response.items.first { $0.id == "artsculture" })
		XCTAssertTrue(artsculture.isCustomTagging)
		XCTAssertFalse(artsculture.isTechnologyFields)
	}

}
