// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsFeatureConstants.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/08/24.
//

import Foundation

enum NewsFeatureConstants {

    public static let clientBaseURL: URL = {
#if TESTINGMACHINE_OAUTH
        return URL(string: "https://api.tourism.testingmachine.eu")!
#else
        return URL(string: "https://tourism.opendatahub.com")!
#endif
    }()
}
