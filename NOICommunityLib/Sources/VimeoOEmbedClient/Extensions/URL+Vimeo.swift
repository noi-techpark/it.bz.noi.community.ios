// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  URL+Vimeo.swift
//  VimeoOEmbedClient
//
//  Created by Matteo Matassoni on 13/01/25.
//

import Foundation

// MARK: - URL+Vimeo

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



