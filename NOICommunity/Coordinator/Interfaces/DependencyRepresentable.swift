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
