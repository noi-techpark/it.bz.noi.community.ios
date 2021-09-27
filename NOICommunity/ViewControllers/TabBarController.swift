//
//  TabBarController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/21.
//

import UIKit

class TabBarController: UITabBarController {
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }
}
