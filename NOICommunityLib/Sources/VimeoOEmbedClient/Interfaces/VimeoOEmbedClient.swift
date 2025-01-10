// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoOEmbedClient.swift
//  VimeoOEmbedClient
//
//  Created by Matteo Matassoni on 09/01/25.
//

import Foundation

// MARK: - VimeoOEmbedError

public enum VimeoOEmbedError: Error {
	case invalidURL
}

// MARK: - VimeoOEmbedClient

public protocol VimeoOEmbedClient {

	func fetchOEmbed(
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
	) async throws -> VimeoOEmbedResponse

}

public extension VimeoOEmbedClient {

	func fetchOEmbed(
		for videoURL: URL,
		width: Int? = nil,
		height: Int? = nil,
		maxWidth: Int? = nil,
		maxHeight: Int? = nil,
		autoplay: Bool? = nil,
		loop: Bool? = nil,
		muted: Bool? = nil,
		title: Bool? = nil,
		byline: Bool? = nil,
		portrait: Bool? = nil,
		dnt: Bool? = nil,
		api: Bool? = nil,
		airplay: Bool? = nil,
		audioTracks: Bool? = nil,
		audioTrack: String? = nil,
		autopause: Bool? = nil,
		background: Bool? = nil,
		callback: String? = nil,
		cc: Bool? = nil,
		chapterID: Int? = nil,
		chapters: Bool? = nil,
		chromecast: Bool? = nil,
		color: String? = nil,
		colors: [String]? = nil,
		controls: Bool? = nil,
		endTime: Int? = nil,
		fullscreen: Bool? = nil,
		interactiveMarkers: Bool? = nil,
		interactiveParams: [String: String]? = nil,
		keyboard: Bool? = nil,
		pip: Bool? = nil,
		playButtonPosition: String? = nil,
		playerID: String? = nil,
		playsinline: Bool? = nil,
		progressBar: Bool? = nil,
		quality: String? = nil,
		qualitySelector: Bool? = nil,
		responsive: Bool? = nil,
		speed: Bool? = nil,
		startTime: Int? = nil,
		textTrack: String? = nil,
		transcript: Bool? = nil,
		transparent: Bool? = nil,
		unmuteButton: Bool? = nil,
		vimeoLogo: Bool? = nil,
		volume: Bool? = nil,
		watchFullVideo: Bool? = nil,
		xhtml: Bool? = nil
	) async throws -> VimeoOEmbedResponse {
		try await fetchOEmbed(
			for: videoURL,
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
	}

}
