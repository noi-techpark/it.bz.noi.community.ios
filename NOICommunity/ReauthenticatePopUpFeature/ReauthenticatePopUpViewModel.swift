// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ReauthenticatePopUpViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/11/25.
//

import Foundation
import Combine

final class ReauthenticatePopUpViewModel {

    private(set) lazy var nextPublisher = nextSubject
        .eraseToAnyPublisher()

    private var nextSubject: PassthroughSubject<Void, Never> = .init()

    init() {}

    func next() {
		nextSubject.send(())
    }
	
}
