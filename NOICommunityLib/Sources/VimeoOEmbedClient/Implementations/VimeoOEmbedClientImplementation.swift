// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoOEmbedClientImplementation.swift
//  VimeoOEmbedClient
//
//  Created by Matteo Matassoni on 09/01/25.
//

import Foundation
import Core

// MARK: - VimeoOEmbedClientImplementation

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
