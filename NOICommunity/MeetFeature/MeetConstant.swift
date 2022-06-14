//
//  MeetConstant.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 26/05/22.
//

import Foundation

enum MeetConstant {
    
    public static let clientBaseURL: URL = {
#if TESTINGMACHINE_OAUTH
        return URL(string: "https://api.community.noi.testingmachine.eu")!
#else
        return URL(string: "https://api.community.noi.opendatahub.bz.it")!
#endif
    }()
    
}
