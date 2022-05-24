//
//  Localization.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 20/09/21.
//

import Foundation

func localizedValue<T>(
    from localizedDict: [String:T],
    defaultValue: T,
    bundle: Bundle = .main
) -> T {
    localizedValue(from: localizedDict) ?? defaultValue
}

func localizedValue<T>(
    from localizedDict: [String:T],
    bundle: Bundle = .main
) -> T? {
    let preferredLanguages = bundle.preferredLocalizations
    for language in preferredLanguages {
        if let localizedValue = localizedDict[language] {
            return localizedValue
        }
    }
    return nil
}
