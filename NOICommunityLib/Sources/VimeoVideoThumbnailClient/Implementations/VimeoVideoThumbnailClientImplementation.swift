// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoVideoThumbnailClientImplementation.swift
//
//
//  Created by Camilla on 23/12/24.
//

import Foundation
import Core
import VimeoOEmbedClient

/*public final class VimeoVideoThumbnailClientImplementation: ThumbnailGeneratorProtocol {

    private struct VimeoResponse: Codable {
        let thumbnail_url_with_play_button: String
    }
    
    /// Generates a thumbnail from a `.m3u8` video URL of a vimeo video
    /// - Parameter m3u8URL: URL of the `.m3u8` video
    /// - Returns: URL of the thumbnail, if available
    public static func generateThumbnail(from videoURL: URL) async -> URL? {
        do {
            let videoID = try extractVideoID(from: videoURL)
            let jsonURL = try getJsonURL(for: videoID)
            let thumbnailURL = try await fetchThumbnailURL(from: jsonURL)
            return thumbnailURL
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    
    
    /// Makes a request to the Vimeo API to fetch the thumbnail
    /// - Parameter apiURL: The Vimeo API URL
    /// - Throws: Error if the request or decoding fails
    /// - Returns: The URL of the thumbnail
    private static func fetchThumbnailURL(from apiURL: URL) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: apiURL)
        
        // Validate the HTTP response status
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ThumbnailError.invalidResponse
        }
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        let vimeoResponse = try decoder.decode(VimeoResponse.self, from: data)
        
        guard let thumbnailURL = URL(string: vimeoResponse.thumbnail_url_with_play_button) else {
            throw ThumbnailError.invalidThumbnailURL
        }
        
        return thumbnailURL
    }
}

enum ThumbnailError: Error {
    case invalidVideoURL
    case invalidVimeoURL
    case invalidAPIURL
    case invalidResponse
    case invalidThumbnailURL
}*/

public final class VimeoVideoThumbnailClientImplementation: VimeoVideoThumbnailClient {

	let vimeoOEmbedClient: VimeoOEmbedClient

	public init(vimeoOEmbedClient: VimeoOEmbedClient) {
		self.vimeoOEmbedClient = vimeoOEmbedClient
	}

	public func fetchThumbnailURL(
		from videoURL: URL,
		width: Int?,
		height: Int?
	) async throws -> URL {
		try await vimeoOEmbedClient.fetchOEmbed(
			for: videoURL,
			width: width,
			height: height
		).thumbnailUrlWithPlayButton
	}

}
