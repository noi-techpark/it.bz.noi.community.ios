// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DeepLinking.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/05/22.
//

import UIKit

// MARK: - DeepLinkIntent

enum DeepLinkIntent {
    case showNews(newsId: String)
    //case showEvent(eventId: String)
}

// MARK: - DeepLinkManager

struct DeepLinkManager {
    
    static func deepLinkIntent(from url: URL) -> DeepLinkIntent? {
        guard let urlComponents = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )
        else { return nil }
        
        guard
            urlComponents.scheme == URLConstant.customURLScheme,
            urlComponents.host == URLConstant.host
        else { return nil }
        
        guard let pathComponents = urlComponents.url?.pathComponents
        else { return nil }
        
        switch pathComponents.count {
        case 3:
            switch (pathComponents[1], pathComponents[2]) {
            case (URLConstant.newsDetailsPath, let newsId):
                // Matches: <customURLScheme><host>/newsDetails/{newsId}
                return .showNews(newsId: newsId)
//            case (URLConstant.eventDetailsPath, let eventId):
//                // Matches: <customURLScheme><host>/eventDetails/{eventId}
//                return .showEvent(eventId: eventId)
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    static func deepLinkIntent(
        from notificationPayload: [AnyHashable: Any]
    ) -> DeepLinkIntent? {
        guard
            let deepLink = notificationPayload[NotificationConstant.deepLinkKey] as? String,
            let deepLinkURL = URL(string: deepLink)
        else { return nil }
        
        return deepLinkIntent(from: deepLinkURL)
    }
    
}

// MARK: Private APIs

private extension DeepLinkManager {
    
    enum URLConstant {
        static let customURLScheme = "noi-community"
        static let host = "it.bz.noi.community"
        static let newsDetailsPath = "newsDetails"
        static let eventDetailsPath = "eventDetails"
    }
    
    enum NotificationConstant {
        static let deepLinkKey = "deep_link"
    }
    
}
