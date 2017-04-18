//
//  JsonDictionary.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

struct JsonDictionary: JsonWrapper, Collection, ExpressibleByDictionaryLiteral {
    
    private let _dictionary: [Key: Value]
    
    init(_ dictionary: [Key: Value]) {
        _dictionary = dictionary
    }
    
    // MARK: - JsonWrapper
    
    subscript(key: String) -> JsonWrapper {
        guard let value = _dictionary[key] else { return JsonValue(nil) }
        return json(value)
    }
    
    var any: Any? {
        var dictionary = _dictionary
        for (key, value) in _dictionary where value is NSNull {
            dictionary[key] = nil
        }
        return dictionary
    }
    
    var dictionary: JsonDictionary {
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
    
    subscript(position: DictionaryIndex<Key, Value>) -> (key: String, value: JsonWrapper) {
        let value = _dictionary[position]
        return (value.key, json(value.value))
    }
    
    var first: JsonWrapper? {
        guard let first = _dictionary.first?.value else { return nil }
        return json(first)
    }
    
    var startIndex: DictionaryIndex<Key, Value> {
        return _dictionary.startIndex
    }
    
    var endIndex: DictionaryIndex<Key, Value> {
        return _dictionary.endIndex
    }
    
    func index(after i: DictionaryIndex<Key, Value>) -> DictionaryIndex<Key, Value> {
        return _dictionary.index(after: i)
    }
    
    // MARK: - ExpressibleByDictionaryLiteral
    
    typealias Key = String
    typealias Value = Any
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = [Key: Value](minimumCapacity: elements.count)
        for (key, value) in elements {
            dictionary[key] = value
        }
        _dictionary = dictionary
    }
    
}

