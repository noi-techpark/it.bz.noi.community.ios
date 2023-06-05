// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  ArrayBuilderTests.swift
//  ArrayBuilderTests
//
//  Created by Matteo Matassoni on 11/05/22.
//

import XCTest
import ArrayBuilder

final class ArrayBuilderTests: XCTestCase {
    let bool = false
    
    func testEmpty() throws {
        expect([]) {}
    }
    
    func testVariadicSingle() throws {
        expect(["hello"]) {
            "hello"
        }
    }
    
    func testVariadicMultiple() throws {
        expect(["hello", "world", "!"]) {
            "hello"
            "world"
            "!"
        }
    }
    
    func testConditionalsIf() throws {
        expect(["true"]) {
            if true {
                "true"
            }
        }
        
        expect([]) {
            if false {
                "true"
            }
        }
    }
    
    func testConditionalsIfElse() throws {
        expect(["true"]) {
            if true {
                "true"
            } else {
                "false"
            }
        }
        
        expect(["false"]) {
            if false {
                "true"
            } else {
                "false"
            }
        }
    }
    
    func testOptional() throws {
        var name: String?
        
        expect(["hello", "unknown"]) {
            "hello"
            if let name = name {
                name
            } else {
                "unknown"
            }
        }
        
        name = "test"
        expect(["hello", "test"]) {
            "hello"
            if let name = name {
                name
            } else {
                "unknown"
            }
        }
    }
    
    func expect(
        _ expected: [String],
        @ArrayBuilder<String> block: () -> [String]
    ) {
        XCTAssertEqual(expected, block())
    }
}
