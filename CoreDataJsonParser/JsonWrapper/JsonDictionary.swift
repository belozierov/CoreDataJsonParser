//
//  JsonDictionary.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

struct JsonDictionary: JsonCollectionWrapper, JsonConvertable {
    
    private let _dictionary: [String: Any]
    
    init(_ dictionary: [String: Any]) {
        _dictionary = dictionary
    }
    
    // MARK: - JsonWrapper
    
    subscript(key: String) -> JsonWrapper? {
        guard let value = _dictionary[key] else { return nil }
        return json(value)
    }
    
    var any: Any {
        return _dictionary
    }
    
    var dictionary: JsonDictionary? {
        return self
    }
    
    // MARK: - Sequence
    
    func makeIterator() -> AnyIterator<(key: String, value: JsonWrapper)> {
        var iterator = _dictionary.makeIterator()
        return AnyIterator {
            guard let next = iterator.next() else { return nil }
            return (next.key, json(next.value))
        }
    }
    
    // MARK: - Collection
    
    subscript(position: DictionaryIndex<String, Any>) -> (key: String, value: JsonWrapper) {
        let value = _dictionary[position]
        return (value.key, json(value.value))
    }
    
    var first: JsonWrapper? {
        guard let first = _dictionary.first?.value else { return nil }
        return json(first)
    }
    
    var startIndex: DictionaryIndex<String, Any> {
        return _dictionary.startIndex
    }
    
    var endIndex: DictionaryIndex<String, Any> {
        return _dictionary.endIndex
    }
    
    func index(after i: DictionaryIndex<String, Any>) -> DictionaryIndex<String, Any> {
        return _dictionary.index(after: i)
    }
    
}

