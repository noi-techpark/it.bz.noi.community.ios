// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventsFeatureConstants.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/21.
//

import Foundation

enum EventsFeatureConstants {

    static let maximumNumberOfEvents = 20

	public static let clientBaseURL: URL = {
#if TESTINGMACHINE_OAUTH
		URL(string: "https://tourism.api.opendatahub.testingmachine.eu")!
#else
		URL(string: "https://tourism.api.opendatahub.com")!
#endif
	}()
}
