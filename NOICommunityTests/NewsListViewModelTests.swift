//
//  NewsViewModelTests.swift
//  NOICommunityTests
//
//  Created by Matteo Matassoni on 11/05/22.
//

import XCTest
import Combine
import ArticlesClient
import ArticlesClientLive
@testable import NOICommunity

class NewsListViewModelTests: XCTestCase {
    
    var viewModel: NewsListViewModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = .init(articlesClient: .live())
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        let newsPublisher = viewModel.$newsIds
            .collectNext(1)
        
        var result: [[String]] = []
        
        viewModel.fetchNews()
        result += try awaitPublisher(newsPublisher)
        
        viewModel.fetchNews()
        result += try awaitPublisher(newsPublisher)
        
        viewModel.fetchNews(refresh: true)
        result += try awaitPublisher(newsPublisher)
        
        XCTAssertNotEqual(result[0], result[1])
        XCTAssertEqual(result[0], result[2])
    }
    
}
