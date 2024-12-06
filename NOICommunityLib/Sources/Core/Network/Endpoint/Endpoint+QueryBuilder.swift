// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+QueryBuilder.swift
//  Core
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation

extension Endpoint {
    
    public init(
        path: String,
        @ArrayBuilder<URLQueryItem> block: () -> [URLQueryItem]
    ) {
        self.init(path: path, queryItems: block())
    }
    
}
