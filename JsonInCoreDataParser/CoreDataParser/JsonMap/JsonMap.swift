//
//  JsonReferenceMap.swift
//  EasyEway
//
//  Created by Beloizerov on 18.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

class JsonMap: NSObject, JsonWrapper {
    
    private let wrapper: JsonWrapper
    final unowned let managedObject: NSManagedObject
    final private(set) var parseOptions: [ParseOption]?
    typealias ParseOption = NSManagedObject.ParseOption
    
    init(_ wrapper: JsonWrapper, managedObject: NSManagedObject, parseOptions: [ParseOption]?) {
        self.wrapper = wrapper
        self.managedObject = managedObject
        self.parseOptions = parseOptions
    }
    
    final var context: NSManagedObjectContext? {
        return managedObject.managedObjectContext
    }
    
    final subscript(options options: ParseOption...) -> JsonMap {
        parseOptions = options
        return self
    }
    
    // MARK: - JsonWrapper
    
    final var any: Any? { return wrapper.any }
    final var isEmpty: Bool { return wrapper.isEmpty }
    final var count: Int { return wrapper.count }
    final var array: JsonArray { return wrapper.array }
    final var dictionary: JsonDictionary { return wrapper.dictionary }
    
    subscript(key: String) -> JsonMap {
        return JsonMap(wrapper[key], managedObject: managedObject, parseOptions: parseOptions)
    }
    
    final subscript(position: Int) -> JsonMap {
        return JsonMap(wrapper[position], managedObject: managedObject, parseOptions: parseOptions)
    }
    
    final func converted<T: SimpleInit>() -> T? {
        return wrapper.converted()
    }
    
}
