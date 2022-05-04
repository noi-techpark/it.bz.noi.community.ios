//
//  NavigationCoordinatorType.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 27/04/22.
//

import UIKit

/// Coordinator protocol. Coordinators are responsible to handle navigations and object creations.
protocol NavigationCoordinatorType: CoordinatorType {
    
    /// Since main task of  coordinators is handling navigation, they directly interract with navigation controllers
    var navigationController: UINavigationController { get set }
    
}
