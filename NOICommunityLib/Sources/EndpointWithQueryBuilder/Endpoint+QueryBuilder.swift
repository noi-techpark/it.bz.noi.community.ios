//
//  Endpoint+QueryBuilder.swift
//  EndpointWithQueryBuilder
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation
import Endpoint
import ArrayBuilder

extension Endpoint {
    
    public init(
        path: String,
        @ArrayBuilder<URLQueryItem> block: () -> [URLQueryItem]
    ) {
        self.init(path: path, queryItems: block())
    }
    
}
