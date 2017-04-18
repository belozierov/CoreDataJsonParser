//
//  JsonWrapper.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

protocol JsonWrapper {
    
    var any: Any? { get }
    
    // MARK: - Values
    
    var string: String? { get }
    var bool: Bool? { get }
    var int: Int? { get }
    var int16: Int16? { get }
    var int32: Int32? { get }
    var int64: Int64? { get }
    var float: Float? { get }
    var double: Double? { get }
    var date: Date? { get }
    var data: Data? { get }
    
    // MARK: - Relations
    
    var array: JsonArray { get }
    var dictionary: JsonDictionary { get }
    subscript(key: String) -> JsonWrapper { get }
    subscript(position: Int) -> JsonWrapper { get }
    
}

extension JsonWrapper {
    
    func transformed(_ function: (JsonWrapper) -> Any?) -> JsonWrapper? {
        guard let any = function(self) else { return nil }
        return json(any)
    }
    
    // MARK: - Values
    
    var string: String? { return nil }
    var bool: Bool? { return nil }
    var int: Int? { return nil }
    var int16: Int16? { return nil }
    var int32: Int32? { return nil }
    var int64: Int64? { return nil }
    var float: Float? { return nil }
    var double: Double? { return nil }
    var date: Date? { return nil }
    var data: Data? { return nil }
    
    // MARK: - Relations
    
    var array: JsonArray { return [self] }
    var dictionary: JsonDictionary { return [:] }
    subscript(key: String) -> JsonWrapper { return JsonValue(nil) }
    subscript(position: Int) -> JsonWrapper { return JsonValue(nil) }
    
}

extension JsonWrapper where Self: JsonConvertable {
    
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

}
