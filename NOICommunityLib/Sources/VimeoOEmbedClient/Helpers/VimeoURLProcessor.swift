// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoURLProcessor.swift
//  VimeoOEmbedClient
//
//  Created by Matteo Matassoni on 13/01/25.
//

// MARK: - VimeoURLProcessor

import Foundation

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
