// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  TopTabCoordinatorType.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/03/2022.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol TopTabCoordinatorType: CoordinatorType {

    /// Since main task of tab coordinators is handling tabs, they directly interact with a tab bar controller
    var topTabBarController: TopTabBarController { get set }

}
