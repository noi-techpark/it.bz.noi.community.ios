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

	private var eventDetailsViewController: EventDetailsViewController? {
		children
			.lazy
			.compactMap { $0 as? EventDetailsViewController }
			.first
	}

	var locateActionHandler: ((Event) -> Void)? {
		didSet {
			eventDetailsViewController?.locateActionHandler = { [weak self] in
				self?.locateActionHandler?($0)
			}
		}
	}

	var addToCalendarActionHandler: ((Event) -> Void)? {
		didSet {
			eventDetailsViewController?.addToCalendarActionHandler = { [weak self] in
				self?.addToCalendarActionHandler?($0)
			}
		}
	}

	var signupActionHandler: ((Event) -> Void)? {
		didSet {
			eventDetailsViewController?.signupActionHandler = { [weak self] in
				self?.signupActionHandler?($0)
			}
		}
	}

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

                self.navigationItem.title = event.title
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

		navigationItem.largeTitleDisplayMode = .never
		embedChild(containerViewController)
	}

}

// MARK: Private APIs

private extension EventPageViewController {

	func show(content: UIViewController) {
		containerViewController.content = content
	}

	func makeResultContent(for event: Event) -> EventDetailsViewController {
		let result = EventDetailsViewController(for: event)
		result.locateActionHandler = { [weak self] in
			self?.locateActionHandler?($0)
		}
		result.addToCalendarActionHandler = { [weak self] in
			self?.addToCalendarActionHandler?($0)
		}
		result.signupActionHandler = { [weak self] in
			self?.signupActionHandler?($0)
		}
		return result
	}

}
