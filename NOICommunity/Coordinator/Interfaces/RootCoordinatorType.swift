//
//  RootCoordinatorType.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/04/22.
//

import UIKit

/// Root coordinator protocol. Root coordinator are responsible to handle the main windows' root view controller.
protocol RootCoordinatorType: CoordinatorType {

    /// Since main task of root coordinators is handling the root view controller, they directly interact with the main window.
    var window: UIWindow { get set }

}
