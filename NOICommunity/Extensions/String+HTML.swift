// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  String+HTML.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 03/11/25.
//

import UIKit

// MARK: - HTML Rendering API

extension String {

	/// Converts HTML string to NSAttributedString
	/// - Parameters:
	///   - textStyle: Text style for Dynamic Type support (default: .body)
	/// - Returns: NSAttributedString or nil if conversion fails
	public func htmlAttributedString(
		textStyle: UIFont.TextStyle = .body
	) -> NSAttributedString? {
		let font = UIFont.preferredFont(forTextStyle: textStyle)

		// Wrap HTML with font and color styling
		let styledHTML = """
		<style>
			body {
				font-family: -apple-system;
				font-size: \(font.pointSize)px;
			}
		</style>
		\(self)
		"""

		guard let data = styledHTML.data(using: .utf8) else {
			return nil
		}

		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding: String.Encoding.utf8.rawValue
		]

		return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
	}
}
