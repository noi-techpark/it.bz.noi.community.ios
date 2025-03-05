// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ContactInfo.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 20/03/25.
//

import Foundation
import Combine
import PeopleClient
import MessageUI
import Contacts

// MARK: - ContactInfo

struct ContactInfo {

	let firstName: String
	let lastName: String
	let fullname: String
	let company: String?
	let email: String?
	let phoneNumber: String?
	
}

extension ContactInfo {

	func toVCard() -> Data? {
		try? CNContactVCardSerialization.data(with: [toCNContact()])
	}

	func toText() -> String {
		[
			fullname,
			company,
			email,
			phoneNumber
		]
			.compactMap { $0 }
			.joined(separator: "\n")
	}

	func toCNContact() -> CNContact {
		// Create a mutable contact
		let contact = CNMutableContact()

		// Set name properties
		contact.givenName = firstName
		contact.familyName = lastName

		if let company {
			contact.organizationName = company
		}

		if let email {
			contact.emailAddresses = [
				CNLabeledValue(
					label: CNLabelWork,
					value: email as NSString
				)
			]
		}

		if let phoneNumber {
			contact.phoneNumbers = [
				CNLabeledValue(
					label: CNLabelWork,
					value: CNPhoneNumber(stringValue: phoneNumber)
				)
			]
		}

		return contact
	}

}
