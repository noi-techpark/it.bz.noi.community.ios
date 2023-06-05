// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIView+Subviews.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//

import UIKit

extension UIView {
    func embedSubview(_ subview: UIView) {
        // do nothing if this view is already in the right place
        guard subview.superview != self
        else { return }

        if subview.superview != nil {
            subview.removeFromSuperview()
        }

        subview.translatesAutoresizingMaskIntoConstraints = false

        subview.frame = bounds
        addSubview(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),

            subview.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }

    func isContainedWithin(_ other: UIView) -> Bool {
        var current: UIView? = self
        while let proposedView = current {
            if proposedView == other {
                return true
            }
            current = proposedView.superview
        }
        return false
    }

    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    func recursiveSubviews(
        matching: (UIView) throws -> Bool = { _ in true }
    ) rethrows -> [UIView] {
        if subviews.isEmpty {
            return []
        }
        var results: [UIView] = []
        for subview in subviews {
            results += try subview.recursiveSubviews(matching: matching)
            if try matching(subview) {
                results.append(subview)
            }
        }
        return results.filter({_ in true })
    }
}
