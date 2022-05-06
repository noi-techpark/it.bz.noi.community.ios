//
//  collectNext.swift
//  NOICommunityTests
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import Combine

extension Published.Publisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        self.dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
