// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Endpoint+Tag.swift
//
//  Created by Camilla on 18/02/25.
//

import Foundation
import Core

extension Endpoint {
    
    static func articleTagList() -> Endpoint {
        Self(path: "/v1/Tag") {
            URLQueryItem(
                name: "validforentity",
                value: "article"
            )

            URLQueryItem(
                name: "types",
                value: "noicommunitycategory"
            )

            URLQueryItem(
                name: "fields",
                value: "Id,TagName,Types"
            )

            URLQueryItem(
                name: "pagesize",
                value: "0"
            )
        }
    }
    
}
