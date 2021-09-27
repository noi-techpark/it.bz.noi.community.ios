//
//  Collection.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//  Copyright © 2019 DIMENSION S.r.l. All rights reserved.
//

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
