// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventTagsClient.swift
//  EventTagsClient
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation

public protocol EventTagsClient {
	func getEventTagList() async throws -> EventTagListResponse
}
