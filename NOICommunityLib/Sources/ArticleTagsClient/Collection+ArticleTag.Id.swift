// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Collection+ArticleTag.Id.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 19/03/25.
//

import Foundation

public extension Collection where Element == ArticleTag.Id {

	/// Converts a collection of tag IDs into a raw filter query string.
	/// Returns an empty string for empty collections or a properly formatted query string.
	func toRawFilterQuery() -> String {
		guard !isEmpty else {
			return ""
		}

		let tagIdFilter: (Element) -> String = {
			#"in(TagIds.[],"\#($0)")"#
		}

		if count == 1,
		   let firstElement = first {
			return tagIdFilter(firstElement)
		}

		return "or(\(map(tagIdFilter).joined(separator: ",")))"
	}
}
