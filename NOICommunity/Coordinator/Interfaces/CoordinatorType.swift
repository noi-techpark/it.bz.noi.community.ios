// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  CoordinatorType.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/2021.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol CoordinatorType: AnyObject {    
    
    /// childCoordinators: child coordinators should be append to this array to keep them alive!
    var childCoordinators: [CoordinatorType] { get set }
    
    /// Coordinators need container for creating view controllers
    var dependencyContainer: DependencyRepresentable { get set }
    
    /// Start function triggers view controller creation and navigations.
    func start(animated: Bool)
}

extension CoordinatorType {
    
    func start() {
        start(animated: false)
    }
    
    /// This method should be called when a child coordinator have finished its job.
    /// - Parameter child: child of the parent going to be terminated.
    func sacrifice(child: CoordinatorType) {
        guard let childPosition = childCoordinators
                .firstIndex(where: { $0 === child })
        else { return }

        childCoordinators.remove(at: childPosition)
    }
    
}
