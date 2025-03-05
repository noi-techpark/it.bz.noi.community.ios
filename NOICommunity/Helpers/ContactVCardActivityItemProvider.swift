// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ContactVCardActivityItemProvider.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 20/03/25.
//


import Foundation
import Combine
import PeopleClient
import MessageUI
import Contacts

final class ContactVCardActivityItemProvider: UIActivityItemProvider, @unchecked Sendable {

	private let fileURL: URL

	override var item: Any { fileURL }

	init(contact: ContactInfo) {
		self.fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(contact.fullname).vcf")
		if let vCard = contact.toVCard() {
			try? vCard.write(to: fileURL)
		}

		super.init(placeholderItem: fileURL)
	}

}
