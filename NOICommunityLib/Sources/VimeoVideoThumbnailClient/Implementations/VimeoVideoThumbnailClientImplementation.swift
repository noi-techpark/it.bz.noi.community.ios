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
		let oEmbedResult = try await vimeoOEmbedClient.fetchOEmbed(
			for: videoURL,
			width: width,
			height: height
		)
		return if requiresPlayButton {
			oEmbedResult.thumbnailUrlWithPlayButton
		} else {
			oEmbedResult.thumbnailUrl
		}
	}

}
