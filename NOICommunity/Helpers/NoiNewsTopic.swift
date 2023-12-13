// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NoiNewsTopic.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 06/05/22.
//

import Foundation

enum NoiNewsTopic: String, CaseIterable {
    case it = "newsfeednoi_it"
    case de = "newsfeednoi_de"
    case en = "newsfeednoi_en"
}

extension Bundle {
    
    var preferredNoiNewsTopic: NoiNewsTopic {
        let languageToTopic = Dictionary(uniqueKeysWithValues: zip(
            ["it", "de", "en"],
            [NoiNewsTopic.it, NoiNewsTopic.de, NoiNewsTopic.en]
        ))
        return localizedValue(
            from: languageToTopic,
            defaultValue: .en,
            bundle: self
        )
    }
    
}
