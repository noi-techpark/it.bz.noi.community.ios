// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CachableVimeoVideoThumbnailClient.swift
//  VimeoVideoThumbnailClient
//
//  Created by Matteo Matassoni on 10/01/25.
//

import Foundation
import Core

// MARK: - CachableVimeoVideoThumbnailClient

public final class CachableVimeoVideoThumbnailClient: VimeoVideoThumbnailClient {

	let wrapped: VimeoVideoThumbnailClient

	struct CacheKey: Hashable {

		var videoURL: URL
		var width: Int?
		var height: Int?
		var requiresPlayButton: Bool

	}

	let cache: Cache<CacheKey, URL> = .init()

	public init(wrapping: VimeoVideoThumbnailClient) {
		wrapped = wrapping
	}

	public func fetchThumbnailURL(
		from videoURL: URL,
		width: Int?,
		height: Int?,
		withPlayButton requiresPlayButton: Bool
	) async throws -> URL {
		let key = CacheKey(
			videoURL: videoURL,
			width: width,
			height: height,
			requiresPlayButton: requiresPlayButton
		)
		if let cachedResult = cache[key] {
			return cachedResult
		} else {
			let result = try await wrapped.fetchThumbnailURL(
				from: videoURL,
				width: width,
				height: height
			)
			cache[key] = result
			return result
		}
	}

}

// MARK: VimeoVideoThumbnailClient+Cache

public extension VimeoVideoThumbnailClient {

	func cached() -> VimeoVideoThumbnailClient {
		CachableVimeoVideoThumbnailClient(wrapping: self)
	}

}
