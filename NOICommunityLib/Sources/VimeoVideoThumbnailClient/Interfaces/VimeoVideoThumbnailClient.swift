// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoThumbnailClient.swift
//  
//
//  Created by Camilla on 23/12/24.
//


import Foundation

public protocol VimeoVideoThumbnailClient {

	func fetchThumbnailURL(
		from videoURL: URL,
		width: Int?,
		height: Int?
	) async throws -> URL

}

public extension VimeoVideoThumbnailClient {

	func fetchThumbnailURL(
		from videoURL: URL,
		width: Int? = nil,
		height: Int? = nil
	) async throws -> URL {
		try await fetchThumbnailURL(
			from: videoURL,
			width: width,
			height: height
		)
	}

}
