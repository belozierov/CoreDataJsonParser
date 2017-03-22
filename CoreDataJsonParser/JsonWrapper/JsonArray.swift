//
//  JsonArray.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

struct JsonArray: JsonCollectionWrapper, JsonConvertable {
    
    private let _array: [Any]
    
    init(_ array: [Any]) {
        _array = array
    }
    
    // MARK: - JsonWrapper
    
    var any: Any {
        return _array
    }
    
    var array: JsonArray? {
        return self
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
        return json(position < endIndex ? _array[position] : NSNull())
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
    
}
