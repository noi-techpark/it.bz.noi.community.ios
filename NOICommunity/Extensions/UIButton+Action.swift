// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIButton+Action.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 05/03/25.
//

import UIKit

extension UIButton {

	public func setAction(_ action: UIAction?, for event: UIControl.Event = .primaryActionTriggered) {
		removeActions(for: event)

		if let action {
			addAction(action, for: event)
		}
	}

	private func removeActions(
		for event: UIControl.Event = .primaryActionTriggered
	) {
		enumerateEventHandlers { currentAction, _, currentEvent, _ in
			guard let currentAction,
				  currentEvent == event
			else { return }

			removeAction(currentAction, for: currentEvent)
		}
	}

}
