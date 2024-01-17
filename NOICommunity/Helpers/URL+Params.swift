// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  URL+Params.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 16/01/24.
//

import Foundation

extension URL {

    func addQueryParams(fullview: Bool) -> URL {
        var urlComponents = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false
        )!
        var queryItems = urlComponents.queryItems ?? []
        if fullview {
            queryItems.append(URLQueryItem(name: "fullview", value: "1"))
        }
        urlComponents.queryItems = !queryItems.isEmpty ? queryItems : nil
        return urlComponents.url!
    }

    func addQueryParams(fullview: Bool, hideZoom: Bool) -> URL {
        var urlComponents = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false
        )!
        var queryItems = urlComponents.queryItems ?? []
        if fullview {
            queryItems.append(URLQueryItem(name: "fullview", value: "1"))
        }
        if hideZoom {
            queryItems.append(URLQueryItem(name: "hidezoom", value: "1"))
        }
        urlComponents.queryItems = !queryItems.isEmpty ? queryItems : nil
        return urlComponents.url!
    }
    
}
