//
//  JsonArray.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

struct JsonArray: JsonWrapper, RandomAccessCollection, ExpressibleByArrayLiteral {
    
    private let _array: [Element]
    
    init(_ array: [Element]) {
        _array = array
    }
    
    // MARK: - JsonWrapper
    
    var any: Any? {
        return _array.flatMap { $0 is NSNull ? nil : $0 }
    }
    
    var array: JsonArray {
        return self
    }
    
    var dictionary: JsonDictionary {
        guard _array.count == 1 else { return [:] }
        return first?.dictionary ?? [:]
    }
    
    // MARK: - Sequence
    
    func makeIterator() -> AnyIterator<JsonWrapper> {
        var iterator = _array.makeIterator()
        return AnyIterator {
            guard let next = iterator.next() else { return nil }
            return json(next)
        }
    }
    
    // MARK: - Collection
    
    var first: JsonWrapper? {
        guard let first = _array.first else { return nil }
        return json(first)
    }
    
    subscript(position: Int) -> JsonWrapper {
        return position < endIndex ? json(_array[position]) : JsonValue()
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return _array.count
    }
    
    func index(after i: Int) -> Int {
        return i + 1
    }
    
    // MARK: - ExpressibleByArrayLiteral
    
    typealias Element = Any
    
    init(arrayLiteral elements: Element...) {
        _array = elements
    }
    
}
