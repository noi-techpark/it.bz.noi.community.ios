// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoOEmbedClientImplementation.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 09/01/25.
//

import Foundation
import Core

public final class VimeoOEmbedClientImplementation: VimeoOEmbedClient {

	private let baseURL = URL(string: "https://vimeo.com")!

	private let transport: Transport

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
		return jsonDecoder
	}()

	public init(transport: Transport) {
		self.transport = transport
			.checkingStatusCodes()
			.addingJSONHeaders()
	}

	public func fetchOEmbed(
		for videoURL: URL,
		width: Int?,
		height: Int?,
		maxWidth: Int?,
		maxHeight: Int?,
		autoplay: Bool?,
		loop: Bool?,
		muted: Bool?,
		title: Bool?,
		byline: Bool?,
		portrait: Bool?,
		dnt: Bool?,
		api: Bool?,
		airplay: Bool?,
		audioTracks: Bool?,
		audioTrack: String?,
		autopause: Bool?,
		background: Bool?,
		callback: String?,
		cc: Bool?,
		chapterID: Int?,
		chapters: Bool?,
		chromecast: Bool?,
		color: String?,
		colors: [String]?,
		controls: Bool?,
		endTime: Int?,
		fullscreen: Bool?,
		interactiveMarkers: Bool?,
		interactiveParams: [String: String]?,
		keyboard: Bool?,
		pip: Bool?,
		playButtonPosition: String?,
		playerID: String?,
		playsinline: Bool?,
		progressBar: Bool?,
		quality: String?,
		qualitySelector: Bool?,
		responsive: Bool?,
		speed: Bool?,
		startTime: Int?,
		textTrack: String?,
		transcript: Bool?,
		transparent: Bool?,
		unmuteButton: Bool?,
		vimeoLogo: Bool?,
		volume: Bool?,
		watchFullVideo: Bool?,
		xhtml: Bool?
	) async throws -> VimeoOEmbedResponse {
		let processedURL = try VimeoURLProcessor.process(url: videoURL)

		let request = Endpoint
			.vimeoOEmbed(
				videoURL: processedURL,
				width: width,
				height: height,
				maxWidth: maxWidth,
				maxHeight: maxHeight,
				autoplay: autoplay,
				loop: loop,
				muted: muted,
				title: title,
				byline: byline,
				portrait: portrait,
				dnt: dnt,
				api: api,
				airplay: airplay,
				audioTracks: audioTracks,
				audioTrack: audioTrack,
				autopause: autopause,
				background: background,
				callback: callback,
				cc: cc,
				chapterID: chapterID,
				chapters: chapters,
				chromecast: chromecast,
				color: color,
				colors: colors,
				controls: controls,
				endTime: endTime,
				fullscreen: fullscreen,
				interactiveMarkers: interactiveMarkers,
				interactiveParams: interactiveParams,
				keyboard: keyboard,
				pip: pip,
				playButtonPosition: playButtonPosition,
				playerID: playerID,
				playsinline: playsinline,
				progressBar: progressBar,
				quality: quality,
				qualitySelector: qualitySelector,
				responsive: responsive,
				speed: speed,
				startTime: startTime,
				textTrack: textTrack,
				transcript: transcript,
				transparent: transparent,
				unmuteButton: unmuteButton,
				vimeoLogo: vimeoLogo,
				volume: volume,
				watchFullVideo: watchFullVideo,
				xhtml: xhtml
			)
			.makeRequest(withBaseURL: baseURL)

		let (data, _) = try await transport.send(request: request)

		try Task.checkCancellation()

		return try jsonDecoder.decode(VimeoOEmbedResponse.self, from: data)
	}

}

extension URL {

	/// Checks if the URL is compatible with Vimeo's video URL schemes.
	func isVimeoCompatible() -> Bool {
		// Ensure the host is "vimeo.com"
		guard host == "vimeo.com" else { return false }

		// Convert the URL to a string for regex matching
		let urlString = absoluteString

		// Define regex patterns for each Vimeo URL type with documentation
		let patterns = [
			// Regular Vimeo video: https://vimeo.com/{video_id}
			#"^https://vimeo\.com/\d+$"#,

			// In a showcase: https://vimeo.com/album/{album_id}/video/{video_id}
			#"^https://vimeo\.com/album/\d+/video/\d+$"#,

			// On a channel: https://vimeo.com/channels/{channel_name}/{video_id}
			#"^https://vimeo\.com/channels/[\w-]+/\d+$"#,

			// In a group: https://vimeo.com/groups/{group_name}/videos/{video_id}
			#"^https://vimeo\.com/groups/[\w-]+/videos/\d+$"#,

			// On Demand video: https://vimeo.com/ondemand/{ondemand_name}/{video_id}
			#"^https://vimeo\.com/ondemand/[\w-]+/\d+$"#,

			// Staff picks: https://vimeo.com/staffpicks/{video_id}
			#"^https://vimeo\.com/staffpicks/\d+$"#
		]

		return patterns.contains { pattern in
			urlString.range(of: pattern, options: .regularExpression) != nil
		}
	}

	/// Extracts the video ID from the URL if possible
	func extractVimeoVideoID() -> String? {
		let patterns: [(pattern: String, group: Int)] = [
			// Standard URL pattern
			(#"vimeo\.com/(\d+)"#, 1),

			// Video in album pattern
			(#"vimeo\.com/album/\d+/video/(\d+)"#, 1),

			// Channel video pattern
			(#"vimeo\.com/channels/[\w-]+/(\d+)"#, 1),

			// Group video pattern
			(#"vimeo\.com/groups/[\w-]+/videos/(\d+)"#, 1),

			// Staff pick
			(#"^https://vimeo\.com/staffpicks/(\d+)"#, 1),

			// On Demand video: https://vimeo.com/ondemand/{ondemand_name}/{video_id}
			(#"^https://vimeo\.com/ondemand/[\w-]+/(\d+)"#, 1),

			// Player embed pattern
			(#"player\.vimeo\.com/external/(\d+)"#, 1),
		]

		let urlString = absoluteString

		for (pattern, group) in patterns {
			do {
				let regex = try NSRegularExpression(pattern: pattern, options: [])
				if let match = regex.firstMatch(in: urlString,
												options: [],
												range: NSRange(urlString.startIndex..., in: urlString)),
				   let range = Range(match.range(at: group), in: urlString) {
					return String(urlString[range])
				}
			} catch {
				print("Regular expression error for pattern \(pattern): \(error.localizedDescription)")
				continue
			}
		}

		return nil
	}
}

struct VimeoURLProcessor {
	/// Converts any compatible Vimeo URL to its canonical form
	static func canonicalURL(from url: URL) -> URL? {
		guard let videoID = url.extractVimeoVideoID() else {
			return nil
		}

		var urlBuilder = URLComponents()
		urlBuilder.scheme = "https"
		urlBuilder.host = "vimeo.com"
		urlBuilder.path = "/" + videoID

		return urlBuilder.url
	}

	/// Validates and processes a Vimeo URL
	static func process(url: URL) throws -> URL {
		guard let result = url.isVimeoCompatible() ? url : canonicalURL(from: url)
		else { throw VimeoOEmbedError.invalidURL }

		return result
	}
}
