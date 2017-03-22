//
//  JsonReferenceMap.swift
//  EasyEway
//
//  Created by Beloizerov on 18.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

class JsonMap: NSObject, JsonWrapper, JsonConvertable {
    
    let wrapper: JsonWrapper
    unowned let managedObject: NSManagedObject
    
    init(_ wrapper: JsonWrapper, managedObject: NSManagedObject) {
        self.wrapper = wrapper
        self.managedObject = managedObject
    }
    
    var context: NSManagedObjectContext? {
        return managedObject.managedObjectContext
    }
    
    // MARK: - JsonWrapper
    
    var any: Any { return wrapper.any }
    var string: String? { return wrapper.string }
    var bool: Bool? { return wrapper.bool }
    var int: Int? { return wrapper.int }
    var int16: Int16? { return wrapper.int16 }
    var int32: Int32? { return wrapper.int32 }
    var int64: Int64? { return wrapper.int64 }
    var float: Float? { return wrapper.float }
    var double: Double? { return wrapper.double }
    var date: Date? { return wrapper.date }
    var data: Data? { return wrapper.data }
    var first: JsonWrapper? { return wrapper.first }
    var array: JsonArray? { return wrapper.array }
    var dictionary: JsonDictionary? { return wrapper.dictionary }
    
    subscript(key: String) -> JsonMap? {
        guard let wrapper = wrapper[key] else { return nil }
        return JsonMap(wrapper, managedObject: managedObject)
    }
    
    subscript(position: Int) -> JsonMap {
        return JsonMap(wrapper[position], managedObject: managedObject)
    }
    
}
