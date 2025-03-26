// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  MeetCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import Foundation
import Combine
import PeopleClient
import MessageUI
import Contacts

// MARK: - MeetCoordinator

final class MeetCoordinator: BaseNavigationCoordinator {

	private var mainVC: MeetMainViewController!

	private var peopleViewModel: PeopleViewModel!

	private var subscriptions: Set<AnyCancellable> = []

	override func start(animated: Bool) {
		peopleViewModel = dependencyContainer.makePeopleViewModel()
		peopleViewModel.showDetailsHandler = { [weak self] in
			self?.showPersonDetail(person: $0, sender: $1)
		}
		peopleViewModel.showFiltersHandler = { [weak self] in
			self?.showFilters(sender: $0)
		}
		peopleViewModel.showFilteredResultsHandler = { [weak self] in
			self?.closeFilters()
		}
		mainVC = dependencyContainer.makeMeetMainViewController(
			viewModel: peopleViewModel
		)
		mainVC.navigationItem.title = .localized("title_meet")
		navigationController.viewControllers = [mainVC]
	}
}

// MARK: Private APIs

private extension MeetCoordinator {

	func showPersonDetail(
		person: Person,
		sender: Any?
	) {
		let company = person.companyId.flatMap {
			peopleViewModel.company(withId: $0)
		}
		let detailVC = dependencyContainer.makePersonDetailsViewController(
			person: person,
			company: company
		)

		detailVC.callActionPublisher.sink {
			UIApplication.shared.phone(company!.phoneNumber!)
		}
		.store(in: &subscriptions)

		detailVC.findActionPublisher.sink { [weak navigationController] in
			navigationController?.showDirectionActionSheet(
				destinationName: company?.name ?? "",
				destinationAddress: company?.fullAddress ?? "",
				animated: true
			)
		}
		.store(in: &subscriptions)

		detailVC.composeMailActionPublisher.sink { [weak navigationController] in
			navigationController?.mailTo(
				person.primaryEmail!,
				delegate: self,
				completion: nil
			)
		}
		.store(in: &subscriptions)

		detailVC.shareAction = { [weak self] in
			self?.shareContact(person: person, company: company)
		}

		detailVC.navigationItem.title = person.fullname
		detailVC.navigationItem.largeTitleDisplayMode = .never
		navigationController.pushViewController(detailVC, animated: true)
	}

	func shareContact(person: Person, company: Company?) {
		let contact = ContactInfo(
			firstName: person.firstname,
			lastName: person.lastname,
			fullname: person.fullname,
			company: company?.name,
			email: person.primaryEmail,
			phoneNumber: company?.phoneNumber
		)

		let activityVC = UIActivityViewController(
			activityItems: [contact.toText(), ContactVCardActivityItemProvider(contact: contact)],
			applicationActivities: nil
		)

		navigationController.present(activityVC, animated: true)
	}

	func showFilters(sender: Any?) {
		let filtersVC = dependencyContainer.makeCompaniesFiltersViewController(
			viewModel: peopleViewModel
		)
		filtersVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "xmark.circle.fill"),
			style: .plain,
			target: self,
			action: #selector(closeFilters)
		)
		filtersVC.modalPresentationStyle = .fullScreen
		navigationController.present(
			NavigationController(rootViewController: filtersVC),
			animated: true,
			completion: nil
		)
	}

	@objc func closeFilters() {
		navigationController.dismiss(animated: true, completion: nil)
	}

}

// MARK: MFMailComposeViewControllerDelegate

extension MeetCoordinator: MFMailComposeViewControllerDelegate {

	func mailComposeController(
		_ controller: MFMailComposeViewController,
		didFinishWith _: MFMailComposeResult,
		error _: Error?
	) {
		controller.dismiss(animated: true, completion: nil)
	}
}


