// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  DependencyRepresentable.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/04/22.
//

import Foundation

typealias DependencyRepresentable = (
    ClientFactory &
    ViewModelFactory &
    ViewControllerFactory
)
