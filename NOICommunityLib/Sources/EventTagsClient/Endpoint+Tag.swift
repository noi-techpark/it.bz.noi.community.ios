// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+Tag.swift
//  EventTagsClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation
import Core

extension Endpoint {

	static func eventTagList() -> Endpoint {
		Self(path: "/v1/Tag") {
			// Per the official swagger spec, "types" is a single
			// comma-separated string, not a repeatable query param — passing
			// it twice happens to work on production (minus 3 technology
			// fields tags silently dropped) but not on the testing
			// environment (only the first occurrence is honored there).
			URLQueryItem(
				name: "types",
				value: "\(Tag.customTagging),\(Tag.technologyFields)"
			)

			URLQueryItem(
				name: "fields",
				value: "Id,TagName,Types"
			)

			URLQueryItem(
				name: "pagesize",
				value: "0"
			)
		}
	}

}
