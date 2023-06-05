// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MapWebViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/10/21.
//

import UIKit

class MapWebViewController: WebViewController {
    override var url: URL? {
        get { super.url }
        set(newURL) {
            super.url = newURL?.addQueryParams(fullview: true, hideZoom: true)
        }
    }
}

private extension URL {
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
