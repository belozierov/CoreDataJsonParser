//
//  JsonWrapper.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

protocol JsonWrapper {
    
    var any: Any? { get }
    
    // MARK: - Relations
    
    var array: JsonArray { get }
    var dictionary: JsonDictionary { get }
    subscript(key: String) -> JsonWrapper { get }
    subscript(position: Int) -> JsonWrapper { get }
    
    // MARK: - JsonConvertable
    
    func converted<T: SimpleInit>() -> T?
    
}

extension JsonWrapper {
    
    func transformed(_ function: (JsonWrapper) -> Any?) -> JsonWrapper? {
        guard let any = function(self) else { return nil }
        return json(any)
    }
    
    // MARK: - Values
    
    var string: String? { return converted() }
    var bool: Bool? { return converted() }
    var int: Int? { return converted() }
    var int16: Int16? { return converted() }
    var int32: Int32? { return converted() }
    var int64: Int64? { return converted() }
    var float: Float? { return converted() }
    var double: Double? { return converted() }
    var date: Date? { return converted() }
    var data: Data? { return converted() }
    
    // MARK: - Relations
    
    var array: JsonArray { return any == nil ? [] : [self] }
    var dictionary: JsonDictionary { return [:] }
    subscript(key: String) -> JsonWrapper { return JsonValue() }
    subscript(position: Int) -> JsonWrapper { return JsonValue() }
    
    // MARK: - Relations
    
    func converted<T: SimpleInit>() -> T? {
        return convert(any: any)
    }
    
    fileprivate func convert<T: SimpleInit>(any: Any?) -> T? {
        switch any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }
    
}

extension JsonWrapper where Self: Collection, Self.Iterator.Element == JsonWrapper {
    
    func converted<T: SimpleInit>() -> T? {
        guard count == 1 else { return nil }
        return convert(any: first?.any)
    }
    
}

