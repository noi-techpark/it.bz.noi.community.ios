// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  TopTabCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/03/22.
//

import UIKit
import Combine

// MARK: - TopTabCoordinator

class TopTabBarController: UIViewController {

    @IBOutlet private var topTabBarContainerView: UIView!
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private var topTabBarHidden: [NSLayoutConstraint]!
    @IBOutlet private var topTabBarNotHidden: [NSLayoutConstraint]!

    var viewControllers: [UIViewController] = [] {
        didSet {
            let oldItems = oldValue.tabBarTitles()
            let items = viewControllers.tabBarTitles()
            guard items != oldItems
            else { return }

            topTabBar.setItems(items)
        }
    }

    private lazy var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private lazy var topTabBar: UISegmentedControl = {
        var builder = SegmentedControlBuilder(
            imageFactory: TopTabBarControlImageFactory()
        )
        builder.tintColor = .noiSecondaryColor.withAlphaComponent(0.8)
        builder.selectedTintedColor = .noiSecondaryColor
        builder.font = .NOI.fixed.bodySemibold
        builder.selectedFont = builder.font
        builder.class = SegmentedControl.self
        let segmentedControl = builder.makeSegmentedControl(
            items: viewControllers.tabBarTitles()
        )
        segmentedControl.clipsToBounds = false
        return segmentedControl
    }()

    private var subscriptions: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureBindings()
        showViewController(at: 0)
        topTabBar.selectedSegmentIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTopTabBarHidden(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTopTabBarHidden(true)
    }
    
    weak var selectedViewController: UIViewController? {
        didSet {
            guard oldValue !== selectedViewController
            else { return }
            
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }

}

// MARK: Private APIs

private extension TopTabBarController {
    
    func setTopTabBarHidden(_ hidden: Bool) {
        guard let navigationBar = navigationController?.navigationBar
        else { return }
        
        let changes = {
            if hidden {
                NSLayoutConstraint.deactivate(self.topTabBarNotHidden)
                NSLayoutConstraint.activate(self.topTabBarHidden)
            } else {
                NSLayoutConstraint.deactivate(self.topTabBarHidden)
                NSLayoutConstraint.activate(self.topTabBarNotHidden)
            }
            self.view.layoutIfNeeded()
        }
        let enqueued = transitionCoordinator?.animateAlongsideTransition(
            in: navigationBar,
            animation: { _ in
                changes()
            },
            completion: { _ in
                changes()
            }
        ) ?? false
        if !enqueued {
            changes()
        }
    }

    func configureViewHierarchy() {
        topTabBarContainerView.addSubview(topTabBar)

        topTabBar.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topTabBar.topAnchor
                .constraint(equalTo: topTabBarContainerView.topAnchor, constant: 1),
            topTabBar.leadingAnchor
                .constraint(equalTo: topTabBarContainerView.leadingAnchor, constant: 17),
            topTabBar.trailingAnchor
                .constraint(equalTo: topTabBarContainerView.trailingAnchor, constant: -17),
            topTabBar.bottomAnchor
                .constraint(equalTo: topTabBarContainerView.bottomAnchor, constant: -17),
        ]
        NSLayoutConstraint.activate(constraints)

        embedChild(pageViewController, in: contentView)
    }

    func configureBindings() {
        topTabBar.publisher(for: .valueChanged)
            .sink { [unowned self, topTabBar] in
                self.showViewController(at: topTabBar.selectedSegmentIndex)
            }
            .store(in: &subscriptions)
    }

    func showViewController(at index: Int) {
        let context: (
            direction: UIPageViewController.NavigationDirection,
            animated: Bool
        )
        if let currentViewController = pageViewController.viewControllers?.last,
           let currentIndex = viewControllers
            .firstIndex(of: currentViewController) {
            context = (
                currentIndex < index ? .forward : .reverse,
                true
            )
        } else {
            context = (.forward, false)
        }

        let viewController = self.viewControllers[index]
        pageViewController.setViewControllers(
            [viewController],
            direction: context.direction,
            animated: context.animated
        )
        
        selectedViewController = viewController
    }

    class SegmentedControl: UISegmentedControl {

        // Removes swipe gesture
        override func gestureRecognizerShouldBegin(
            _ gestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Force a square shape
            layer.cornerRadius = 0
        }

    }

}

private extension Array where Element == UIViewController {

    func tabBarTitles() -> [String] {
        map(\.tabBarItem.title).map { $0 ?? "" }
    }

}

private extension UISegmentedControl {

    func setItems(_ titles: [String]) {
        removeAllSegments()
        titles.reversed().forEach {
            self.insertSegment(withTitle: $0, at: 0, animated: false)
        }
    }

}
