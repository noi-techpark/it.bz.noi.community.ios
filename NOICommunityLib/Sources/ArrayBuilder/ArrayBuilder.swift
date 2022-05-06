//
//  ArrayBuilder.swift
//  ArrayBuilder
//
//  Created by Matteo Matassoni on 11/05/22.
//

import Foundation

@resultBuilder
public struct ArrayBuilder<Element> {
    
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.flatMap { $0 }
    }
    
    // Elements: empty
    public static func buildBlock() -> [Element] {
        []
    }
    
    // Elements: not empty case (variadic)
    public static func buildBlock(_ elements: Element...) -> [Element] {
        elements
    }
    
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }
    
    public static func buildExpression(_ expression: ()) -> [Element] {
        []
    }
    
    // Conditionals: if
    public static func buildIf(_ element: [Element]?) -> [Element] {
        element ?? []
    }
    
    // Conditionals: if/else
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }
    public static func buildEither(second: [Element]) -> [Element] {
        second
    }
    
    // Optional
    static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }
}

// MARK: - Array.init(builder:)

public extension Array {
    
    init(@ArrayBuilder<Element> builder: () -> [Element]) {
        self.init(builder())
    }
    
}
