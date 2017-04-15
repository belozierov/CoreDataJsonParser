//
//  JsonWrapper.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

protocol JsonWrapper {
    
    var any: Any { get }
    
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
    
    var first: JsonWrapper? { get }
    var array: JsonArray? { get }
    var dictionary: JsonDictionary? { get }
    subscript(key: String) -> JsonWrapper? { get }
    subscript(position: Int) -> JsonWrapper { get }
    
}

extension JsonWrapper {
    
    func transformed(_ function: (JsonWrapper) -> Any?) -> JsonWrapper? {
        guard let any = function(self) else { return nil }
        return json(any)
    }
    
    // MARK: - Relations
    
    var first: JsonWrapper? { return nil }
    var array: JsonArray? { return nil }
    var dictionary: JsonDictionary? { return nil }
    subscript(key: String) -> JsonWrapper? { return nil }
    subscript(position: Int) -> JsonWrapper { return JsonValue(NSNull()) }
    
}

extension JsonWrapper where Self: JsonConvertable {
    
    var string: String? { return convert(to: String.self) }
    var bool: Bool? { return convert(to: Bool.self) }
    var int: Int? { return convert(to: Int.self) }
    var int16: Int16? { return convert(to: Int16.self) }
    var int32: Int32? { return convert(to: Int32.self) }
    var int64: Int64? { return convert(to: Int64.self) }
    var float: Float? { return convert(to: Float.self) }
    var double: Double? { return convert(to: Double.self) }
    var date: Date? { return convert(to: Date.self) }
    var data: Data? { return convert(to: Data.self) }

}
