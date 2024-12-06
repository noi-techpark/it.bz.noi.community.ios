// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BaseViewModel.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 04/12/24.
//

import Foundation
import Combine

open class BasePageViewModel {

	public var cancellables: Set<AnyCancellable> = []

	public required init() {
		configureBindings()
	}

	open func configureBindings() {}

	open func onViewDidLoad() {}

	open func onViewWillAppear(_ animated: Bool) { }

	open func onViewDidAppear(_ animated: Bool) { }

	open func onViewWillDisappear(_ animated: Bool) { }

	open func onViewDidDisappear(_ animated: Bool) { }

}
