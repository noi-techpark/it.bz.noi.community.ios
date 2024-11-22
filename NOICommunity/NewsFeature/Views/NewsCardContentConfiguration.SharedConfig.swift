// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsCardContentConfiguration.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/05/22.
//

import UIKit
import ArticlesClient

let publishedDateFormatter: DateFormatter = { publishedDateFormatter in
    publishedDateFormatter.dateStyle = .short
    publishedDateFormatter.timeStyle = .none
    return publishedDateFormatter
}(DateFormatter())

extension NewsCardContentConfiguration {
    static func makeContentConfiguration(
        for item: Article
    ) -> NewsCardContentConfiguration {
        var contentConfiguration = NewsCardContentConfiguration()
        
        let author = localizedValue(from: item.languageToAuthor)
        contentConfiguration.authorText = author?.name ?? .notDefined
        
        contentConfiguration.publishedDateText = item.date
            .flatMap { publishedDateFormatter.string(from: $0) }
        
        let details = localizedValue(from: item.languageToDetails)
        contentConfiguration.titleText = details?.title
        contentConfiguration.abstractText = details?.abstract
        
        contentConfiguration.badgeText = if item.isImportant {
            .localized("important_tag")
        } else if item.isHighlighted {
            "TMP PINNATO"
        } else {
            nil
        }
        contentConfiguration.badgeTextProprieties.transform = .uppercase
        
        return contentConfiguration
    }
}
