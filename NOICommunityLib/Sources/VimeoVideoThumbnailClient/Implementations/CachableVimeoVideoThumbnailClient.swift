// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CachableVimeoVideoThumbnailClient.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 10/01/25.
//

import Foundation
import Core

public final class CachableVimeoVideoThumbnailClient: VimeoVideoThumbnailClient {

	let wrapped: VimeoVideoThumbnailClient
	let cache: Cache<CacheKey, URL> = .init()

	public init(wrapping: VimeoVideoThumbnailClient) {
		wrapped = wrapping
	}

	public func fetchThumbnailURL(
		from videoURL: URL,
		width: Int?,
		height: Int?
	) async throws -> URL {
		let key = CacheKey(
			videoURL: videoURL,
			width: width,
			height: height
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

extension CachableVimeoVideoThumbnailClient {

	struct CacheKey: Hashable {

		var videoURL: URL
		var width: Int?
		var height: Int?

	}

}

public extension VimeoVideoThumbnailClient {

	func cached() -> VimeoVideoThumbnailClient {
		CachableVimeoVideoThumbnailClient(wrapping: self)
	}

}
