// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIWindow+topViewController.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 06/12/24.
//

import UIKit

public extension UIWindow {

	var topViewController: UIViewController? {
		topMostViewController(from: rootViewController)
	}

}

private extension UIWindow {

	func topMostViewController(
		from viewController: UIViewController?
	) -> UIViewController? {
		if let presentedViewController = viewController?.presentedViewController {
			topMostViewController(from: presentedViewController)
		} else if let tabBarController = viewController as? UITabBarController {
			topMostViewController(from: tabBarController.selectedViewController)
		} else if let navigationController = viewController as? UINavigationController,
				  let topViewController = navigationController.topViewController {
			topMostViewController(from: topViewController)
		} else {
			viewController
		}
	}

}
