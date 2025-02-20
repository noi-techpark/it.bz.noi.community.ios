// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoURLTests.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 09/01/25.
//

import XCTest

@testable import VimeoOEmbedClient

final class VimeoURLTests: XCTestCase {

	func testRegularVimeoVideoURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/12345678"))
		XCTAssertTrue(url.isVimeoCompatible(), "Should recognize a regular Vimeo video URL.")
	}

	func testShowcaseVideoURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/album/987654/video/12345678"))
		XCTAssertTrue(url.isVimeoCompatible(), "Should recognize a Vimeo showcase video URL.")
	}

	func testChannelVideoURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/channels/mychannel/12345678"))
		XCTAssertTrue(url.isVimeoCompatible(), "Should recognize a Vimeo channel video URL.")
	}

	func testGroupVideoURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/groups/mygroup/videos/12345678"))
		XCTAssertTrue(url.isVimeoCompatible(), "Should recognize a Vimeo group video URL.")
	}

	func testOnDemandVideoURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/ondemand/myvideo/12345678"))
		XCTAssertTrue(url.isVimeoCompatible(), "Should recognize a Vimeo On Demand video URL.")
	}

	func testInvalidHostURL() throws {
		let url = try XCTUnwrap(URL(string: "https://invalid.com/12345678"))
		XCTAssertFalse(url.isVimeoCompatible(), "Should reject a URL with an invalid host.")
	}

	func testInvalidFormatURL() throws {
		let url = try XCTUnwrap(URL(string: "https://vimeo.com/invalid/format"))
		XCTAssertFalse(url.isVimeoCompatible(), "Should reject a URL with an invalid format.")
	}

	func testInvalidVimeoPlayerURL() throws {
		let url = try XCTUnwrap(URL(string: "https://player.vimeo.com/external/1024278566.m3u8?s=cbcbf4d98e7a731751c7361dd2d037ac1e4aa62e&logging=false"))
		XCTAssertFalse(url.isVimeoCompatible(), "Should reject a URL with an invalid format.")
	}

}
