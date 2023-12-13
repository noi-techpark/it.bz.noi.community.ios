// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ContainerViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//

import UIKit

public class ContainerViewController: UIViewController {

    private var _content: UIViewController?
    @objc public var content: UIViewController? {
        get { _content }
        set { setContent(newValue, animated: false) }
    }

    @objc(setContent:animated:)
    public func setContent(_ content: UIViewController?, animated: Bool) {
        let oldContent = _content
        _content = content

        guard isViewLoaded
        else { return }

        replaceChild(oldContent, with: content, animated: animated)

        if content != oldContent {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    @objc
    public init(content: UIViewController?) {
        _content = content
        super.init(nibName: nil, bundle: nil)
    }

    @objc
    convenience public init() {
        self.init(content: nil)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        replaceChild(nil, with: content, animated: false)
    }

    private func replaceChild(_ oldChild: UIViewController?,
                              with newChild: UIViewController?,
                              animated: Bool) {
        let duration: TimeInterval
        let options: UIView.AnimationOptions

        if animated {
            duration = 0.3
            options = [.transitionCrossDissolve, .beginFromCurrentState]
        } else {
            duration = 0
            options = [.beginFromCurrentState]
        }

        switch (oldChild, newChild) {
        case let (old?, new?):
            transition(from: old,
                       to: new,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (nil, let new?):
            transition(to: new,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (let old?, nil):
            transition(from: old,
                       in: view,
                       animated: animated,
                       duration: duration,
                       options: options,
                       completion: nil)
        case (nil, nil):
            return
        }
    }

    private func transition(to: UIViewController,
                            in container: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        addChild(to)
        to.view.alpha = 0
        container.embedSubview(to.view)

        let animationBlock = {
            to.view.alpha = 1
        }
        let animationCompletionBlock = { (finished: Bool) -> Void in
            to.didMove(toParent: self)
            completion?(finished)
        }

        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: animationBlock,
                           completion: animationCompletionBlock)
        } else {
            animationBlock()
            animationCompletionBlock(true)
        }
    }

    private func transition(from: UIViewController,
                            in container: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        // animate out the "from" view
        // remove it
        from.willMove(toParent: nil)

        let animationBlock = {
            from.view.alpha = 0
        }
        let animationCompletionBlock = { (finished: Bool) -> Void in
            from.view.removeFromSuperview()
            from.removeFromParent()

            completion?(finished)
        }

        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: animationBlock,
                           completion: animationCompletionBlock)
        } else {
            animationBlock()
            animationCompletionBlock(true)
        }
    }

    private func transition(from: UIViewController,
                            to: UIViewController,
                            in container: UIView,
                            animated: Bool,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions,
                            completion: ((Bool) -> Void)?) {
        guard from != to
        else { return }

        // animate from "from" view to "to" view
        from.willMove(toParent: nil)
        addChild(to)

        to.view.alpha = 0
        from.view.alpha = 1

        container.embedSubview(to.view)
        container.bringSubviewToFront(from.view)

        let animationBlock = {
            to.view.alpha = 1
            from.view.alpha = 0
        }
        let animationCompletionBlock = { (finished: Bool) -> Void in
            from.view.removeFromSuperview()
            from.removeFromParent()

            to.didMove(toParent: self)

            completion?(finished)
        }

        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: animationBlock,
                           completion: animationCompletionBlock)
        } else {
            animationBlock()
            animationCompletionBlock(true)
        }
    }
}

// MARK: Status Bar

extension ContainerViewController {

    public override var childForStatusBarStyle: UIViewController? {
        content
    }

    public override var childForStatusBarHidden: UIViewController? {
        content
    }
}

// MARK: Home Indicator

extension ContainerViewController {

    public override var childForHomeIndicatorAutoHidden: UIViewController? {
        content
    }
}

// MARK: Screen-edge gestures

extension ContainerViewController {

    public override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        content
    }
}
