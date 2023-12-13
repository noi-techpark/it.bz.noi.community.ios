// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Cache.swift
//  Core
//
//  Created by Matteo Matassoni on 11/03/22.
//

import Foundation

// MARK: - Cache

public final class Cache<Key: Hashable, Value> {

    private let wrapped: NSCache<WrappedKey, Entry> = NSCache()

    public init() {
        // Nothing to do
    }

    public func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    public func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    public subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            if let value = newValue {
                insert(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }

}

// MARK: Private APIs

private extension Cache {

    final class WrappedKey: NSObject {

        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey
            else { return false }

            return value.key == key
        }

    }

    final class Entry {
        let value: Value

        init(value: Value) {
            self.value = value
        }
    }

}
