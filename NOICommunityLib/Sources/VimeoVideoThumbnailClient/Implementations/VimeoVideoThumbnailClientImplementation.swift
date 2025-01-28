// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoThumbnailClientImplementation.swift
//	VimeoVideoThumbnailClient
//
//  Created by Camilla on 23/12/24.
//

import Foundation
import Core
import VimeoOEmbedClient

// MARK: - VimeoVideoThumbnailClientImplementation

public final class VimeoVideoThumbnailClientImplementation: VimeoVideoThumbnailClient {

	let vimeoOEmbedClient: VimeoOEmbedClient

	public init(vimeoOEmbedClient: VimeoOEmbedClient) {
		self.vimeoOEmbedClient = vimeoOEmbedClient
	}

	public func fetchThumbnailURL(
		from videoURL: URL,
		width: Int?,
		height: Int?,
		withPlayButton requiresPlayButton: Bool
	) async throws -> URL {
		let oEmbedResult = try await vimeoOEmbedClient
			.fetchOEmbed(for: videoURL)
		let thumbnailURL = if requiresPlayButton {
			oEmbedResult.thumbnailUrlWithPlayButton
		} else {
			oEmbedResult.thumbnailUrl
		}

		if let width, let height {
			return thumbnailURL
				.replacingDimensions(
					width: width,
					height: height
				) ?? thumbnailURL
		} else {
			return thumbnailURL
		}
	}

}

extension URL {

	/// Replaces the dimensions in a Vimeo-style URL that contains "-d_WxH" format
	/// - Parameters:
	///   - width: The new width to set
	///   - height: The new height to set
	/// - Returns: A new URL with updated dimensions, or nil if modification fails
	func replacingDimensions(width: Int, height: Int) -> URL? {
		let pattern = #"-d_\d+x\d+"#

		do {
			let regex = try NSRegularExpression(pattern: pattern, options: [])
			let range = NSRange(absoluteString.startIndex..., in: absoluteString)

			let modifiedURLString = regex.stringByReplacingMatches(
				in: absoluteString,
				options: [],
				range: range,
				withTemplate: "-d_\(width)x\(height)"
			)

			return URL(string: modifiedURLString)
		} catch {
			return nil
		}
	}

}
