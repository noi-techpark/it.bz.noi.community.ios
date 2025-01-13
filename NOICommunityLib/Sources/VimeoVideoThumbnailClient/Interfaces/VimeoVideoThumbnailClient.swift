// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoThumbnailClient.swift
//  VimeoVideoThumbnailClient
//
//  Created by Camilla on 23/12/24.
//


import Foundation

// MARK: - VimeoVideoThumbnailClient

/// A protocol for fetching thumbnail URLs for Vimeo videos.
public protocol VimeoVideoThumbnailClient {

	/// Fetches the thumbnail URL for a given Vimeo video URL.
	///
	/// - Parameters:
	///   - videoURL: The URL of the Vimeo video for which to fetch the thumbnail.
	///   - width: An optional width for the desired thumbnail in pixels. If `nil`, the default width is used.
	///   - height: An optional height for the desired thumbnail in pixels. If `nil`, the default height is used.
	///
	/// - Returns: The URL of the thumbnail image.
	///
	/// - Throws: An error if the thumbnail could not be fetched. Possible errors might include:
	///   - An invalid video URL.
	///   - Network-related issues.
	///   - The video not having a thumbnail.
	///
	/// - Note: This method is asynchronous and should be awaited.
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

public extension VimeoVideoThumbnailClient {

	/// Fetches thumbnail URLs for a list of Vimeo video URLs.
	///
	/// - Parameters:
	///   - videoURLs: An array of Vimeo video URLs for which to fetch the thumbnails.
	///   - width: An optional width for the desired thumbnails in pixels. If `nil`, the default width is used. Defaults to `nil`.
	///   - height: An optional height for the desired thumbnails in pixels. If `nil`, the default height is used. Defaults to `nil`.
	///
	/// - Returns: A dictionary mapping each video URL to its corresponding thumbnail URL.
	///   - The value is `nil` if the thumbnail URL could not be fetched for a particular video.
	///
	/// - Note: This method is asynchronous and should be awaited.
	func fetchThumbnailURLs(
		from videoURLs: [URL],
		width: Int? = nil,
		height: Int? = nil
	) async -> [URL: URL?] {
		await withTaskGroup(of: (URL, URL?).self) { group in
			for videoURL in videoURLs {
				group.addTask {
					do {
						let thumbnailURL = try await self.fetchThumbnailURL(
							from: videoURL,
							width: width,
							height: height
						)
						return (videoURL, thumbnailURL)
					} catch {
                        return (videoURL, nil)
                    }
				}
			}

			var thumbnailURLs: [URL:URL?] = [:]

			for await (videoURL, thumbnailURL) in group {
				thumbnailURLs[videoURL] = thumbnailURL
			}


			return thumbnailURLs
		}
	}

}
