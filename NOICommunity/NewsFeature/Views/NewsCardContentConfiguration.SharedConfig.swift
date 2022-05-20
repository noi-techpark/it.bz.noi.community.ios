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
        
        contentConfiguration.badgeText = item.isImportant
        ? .localized("important_tag")
        : nil
        var badgeTextProprieties = ContentConfiguration.TextProperties()
        badgeTextProprieties.transform = .uppercase
        contentConfiguration.badgeTextProprieties = badgeTextProprieties
        
        return contentConfiguration
    }
}
