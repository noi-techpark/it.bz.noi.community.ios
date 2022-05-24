////
////  Mocks.swift
////  ArticlesClient
////
////  Created by Matteo Matassoni on 10/05/22.
////
//
//import Foundation
//import Combine
//
//extension ArticlesClient {
//    
//    public static let empty = Self(
//        list: { _, _, _ in
//            Just(ArticleListResponse(
//                totalResults: 0,
//                totalPages: 0,
//                currentPage: 1,
//                previousPage: nil,
//                nextPage: nil,
//                items: []
//            ))
//                .setFailureType(to: Error.self)
//                .eraseToAnyPublisher()
//        },
//        detail: { _, _ in
//            Fail(error: NSError(domain: "", code: 1))
//                .eraseToAnyPublisher()
//        }
//    )
//    
//    public static let happyPath = empty
//    
//    public static let failed = Self(
//        list: { _, _, _ in
//            Fail(error: NSError(domain: "", code: 1))
//                .eraseToAnyPublisher()
//        },
//        detail: { _, _ in
//            Fail(error: NSError(domain: "", code: 1))
//                .eraseToAnyPublisher()
//        }
//    )
//}
