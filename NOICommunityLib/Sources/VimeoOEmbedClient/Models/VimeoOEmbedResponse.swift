// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  VimeoOEmbedResponse.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 09/01/25.
//

import Foundation

public struct VimeoOEmbedResponse: Codable {

	public var type: String
	public var version: String
	public var providerName: String
	public var providerUrl: String
	public var title: String
	public var authorName: String
	public var authorUrl: String
	public var isPlus: String?
	public var html: String
	public var width: Int
	public var height: Int
	public var duration: Int
	public var description: String?
	public var thumbnailUrl: URL
	public var thumbnailUrlWithPlayButton: URL
	public var thumbnailWidth: Int
	public var thumbnailHeight: Int
	public var uploadDate: String

}
