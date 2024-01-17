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
