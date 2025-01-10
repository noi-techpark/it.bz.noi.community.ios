// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+VimeoOEmbed.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 09/01/25.
//

import Foundation
import Core

// MARK: - Endpoint+VimeoOEmbed

extension Endpoint {

	static func vimeoOEmbed(
		videoURL: URL,
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
	) -> Endpoint {
		return Self(path: "/api/oembed.json") {
			// Mandatory parameter
			URLQueryItem(name: "url", value: videoURL.absoluteString)

			// Optional parameters in the specified order
			if let width { URLQueryItem(name: "width", value: String(width)) }
			if let height { URLQueryItem(name: "height", value: String(height)) }
			if let maxWidth { URLQueryItem(name: "maxwidth", value: String(maxWidth)) }
			if let maxHeight { URLQueryItem(name: "maxheight", value: String(maxHeight)) }

			// Boolean parameters (converted to "true"/"false")
			if let autoplay { URLQueryItem(name: "autoplay", value: autoplay ? "true" : "false") }
			if let loop { URLQueryItem(name: "loop", value: loop ? "true" : "false") }
			if let muted { URLQueryItem(name: "muted", value: muted ? "true" : "false") }
			if let title { URLQueryItem(name: "title", value: title ? "true" : "false") }
			if let byline { URLQueryItem(name: "byline", value: byline ? "true" : "false") }
			if let portrait { URLQueryItem(name: "portrait", value: portrait ? "true" : "false") }
			if let dnt { URLQueryItem(name: "dnt", value: dnt ? "true" : "false") }
			if let api { URLQueryItem(name: "api", value: api ? "true" : "false") }
			if let airplay { URLQueryItem(name: "airplay", value: airplay ? "true" : "false") }
			if let audioTracks { URLQueryItem(name: "audio_tracks", value: audioTracks ? "true" : "false") }
			if let audioTrack { URLQueryItem(name: "audiotrack", value: audioTrack) }
			if let autopause { URLQueryItem(name: "autopause", value: autopause ? "true" : "false") }
			if let background { URLQueryItem(name: "background", value: background ? "true" : "false") }
			if let callback { URLQueryItem(name: "callback", value: callback) }
			if let cc { URLQueryItem(name: "cc", value: cc ? "true" : "false") }
			if let chapterID { URLQueryItem(name: "chapter_id", value: String(chapterID)) }
			if let chapters { URLQueryItem(name: "chapters", value: chapters ? "true" : "false") }
			if let chromecast { URLQueryItem(name: "chromecast", value: chromecast ? "true" : "false") }
			if let color { URLQueryItem(name: "color", value: color) }
			if let colors { URLQueryItem(name: "colors", value: colors.joined(separator: ",")) }
			if let controls { URLQueryItem(name: "controls", value: controls ? "true" : "false") }
			if let endTime { URLQueryItem(name: "end_time", value: String(endTime)) }
			if let fullscreen { URLQueryItem(name: "fullscreen", value: fullscreen ? "true" : "false") }
			if let interactiveMarkers { URLQueryItem(name: "interactive_markers", value: interactiveMarkers ? "true" : "false") }
			if let interactiveParams {
				for (key, value) in interactiveParams {
					URLQueryItem(name: "interactive_params[\(key)]", value: value)
				}
			}
			if let keyboard { URLQueryItem(name: "keyboard", value: keyboard ? "true" : "false") }
			if let pip { URLQueryItem(name: "pip", value: pip ? "true" : "false") }
			if let playButtonPosition { URLQueryItem(name: "play_button_position", value: playButtonPosition) }
			if let playerID { URLQueryItem(name: "player_id", value: playerID) }
			if let playsinline { URLQueryItem(name: "playsinline", value: playsinline ? "true" : "false") }
			if let progressBar { URLQueryItem(name: "progress_bar", value: progressBar ? "true" : "false") }
			if let quality { URLQueryItem(name: "quality", value: quality) }
			if let qualitySelector { URLQueryItem(name: "quality_selector", value: qualitySelector ? "true" : "false") }
			if let responsive { URLQueryItem(name: "responsive", value: responsive ? "true" : "false") }
			if let speed { URLQueryItem(name: "speed", value: speed ? "true" : "false") }
			if let startTime { URLQueryItem(name: "start_time", value: String(startTime)) }
			if let textTrack { URLQueryItem(name: "texttrack", value: textTrack) }
			if let transcript { URLQueryItem(name: "transcript", value: transcript ? "true" : "false") }
			if let transparent { URLQueryItem(name: "transparent", value: transparent ? "true" : "false") }
			if let unmuteButton { URLQueryItem(name: "unmute_button", value: unmuteButton ? "true" : "false") }
			if let vimeoLogo { URLQueryItem(name: "vimeo_logo", value: vimeoLogo ? "true" : "false") }
			if let volume { URLQueryItem(name: "volume", value: volume ? "true" : "false") }
			if let watchFullVideo { URLQueryItem(name: "watch_full_video", value: watchFullVideo ? "true" : "false") }
			if let xhtml { URLQueryItem(name: "xhtml", value: xhtml ? "true" : "false") }
		}
	}


}
