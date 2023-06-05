// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  TabCoordinatorType.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol TabCoordinatorType: CoordinatorType {

    /// Since main task of tab coordinators is handling tabs, they directly interact with a tab bar controller
    var tabBarController: UITabBarController { get set }

}
