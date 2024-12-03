// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventPageViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 03/12/24.
//

import UIKit
import CoreUI

// MARK: - EventPageViewController

final class EventPageViewController: BasePageViewController<EventDetailsViewModel> {

	private lazy var containerViewController = ContainerViewController()

	var locateActionHandler: ((Event) -> Void)?

	var addToCalendarActionHandler: ((Event) -> Void)?

	var signupActionHandler: ((Event) -> Void)?

	override func configureBindings() {
		super.configureBindings()

		viewModel.$isLoading
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isLoading in
				if isLoading {
					self?.show(content: LoadingViewController())
				}
			}
			.store(in: &subscriptions)

		viewModel.$result
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] event in
				guard let self
				else { return }

				self.show(content: self.makeResultContent(for: event))
			}
			.store(in: &subscriptions)

		viewModel.$error
			.compactMap { $0 }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] error in
				self?.showError(error)
			}
			.store(in: &subscriptions)
	}

	override func configureLayout() {
		super.configureLayout()

		embedChild(containerViewController)
	}

}

// MARK: Private APIs

private extension EventPageViewController {

	func show(content: UIViewController) {
		containerViewController.content = content
	}

	func makeResultContent(for event: Event) -> UIViewController {
		let result = EventDetailsViewController(for: event)
		result.locateActionHandler = locateActionHandler
		result.addToCalendarActionHandler = addToCalendarActionHandler
		result.signupActionHandler = signupActionHandler
		return result
	}

}
