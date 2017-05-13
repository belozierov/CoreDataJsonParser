//
//  JsonDictionary.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

struct JsonDictionary: JsonWrapper, Collection, ExpressibleByDictionaryLiteral {
    
    private let _dictionary: [String: Any]
    
    init(_ dictionary: [String: Any]) {
        _dictionary = dictionary
    }
    
    // MARK: - JsonWrapper
    
    subscript(key: String) -> JsonWrapper {
        guard let value = _dictionary[key] else { return JsonValue() }
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
    
    var array: JsonArray {
        return _dictionary.isEmpty ? [] : [self]
    }
    
    func converted<T: SimpleInit>() -> T? {
        return nil
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
    
    var isEmpty: Bool {
        return _dictionary.isEmpty
    }
    
    var count: Int {
        return _dictionary.count
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
    
    // MARK: - ExpressibleByDictionaryLiteral
    
    init(dictionaryLiteral elements: (String, Any)...) {
        var dictionary = [String: Any](minimumCapacity: elements.count)
        for (key, value) in elements {
            dictionary[key] = value
        }
        _dictionary = dictionary
    }
    
}

