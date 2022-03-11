//
//  KeyedDecodingContainer+EmptyRepresentable.swift
//  EmptyRepresentable
//
//  Created by Matteo Matassoni on 16/09/21.
//

import Foundation

// MARK: - EmptyRepresentable

/// A type that has an "empty" representation.
public protocol EmptyRepresentable {

    static func empty() -> Self

}

// MARK: - Array+EmptyRepresentable

extension Array: EmptyRepresentable {

    public static func empty() -> Array<Element> {
        []
    }

}

// MARK: - Dictionary+EmptyRepresentable

extension Dictionary: EmptyRepresentable {

    public static func empty() -> Dictionary<Key, Value> {
        [:]
    }

}

// MARK: - KeyedDecodingContainer+EmptyRepresentable

public extension KeyedDecodingContainer {

    func decode<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> T where T: Decodable & EmptyRepresentable {
        if let result = try decodeIfPresent(T.self, forKey: key) {
            return result
        } else {
            return T.empty()
        }
    }

}
