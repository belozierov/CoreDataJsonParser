//
//  NSManagedObject.swift
//  JsonInCoreDataParser
//
//  Created by Beloizerov on 03.02.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    enum Options {
        case onlyAttributes
    }
    
    // MARK: - Public parsing
    
    func parse(_ any: Any, options: [Options]? = nil) {
        switch any {
        case let data as Data: parse(json(data), options: options)
        case let string as String: parse(json(string), options: options)
        default: parse(json(any), options: options)
        }
    }
    
    func parsed(_ any: Any, options: [Options]? = nil) -> Self {
        parse(any, options: options)
        return self
    }
    
    func parsed(_ wrapper: JsonWrapper, options: [Options]? = nil) -> Self {
        parse(wrapper, options: options)
        return self
    }
    
    func parse(_ string: String, options: [Options]? = nil) {
        parse(json(string), options: options)
    }
    
    func parse(_ data: Data, options: [Options]? = nil) {
        parse(json(data), options: options)
    }
    
    func parse(_ dict: [String: Any], options: [Options]? = nil) {
        let relationships = options?.contains(.onlyAttributes) == true ? nil : entity.relationshipsByName
        parse(json: JsonDictionary(dict), attributes: entity.attributesByName, relationships: relationships)
    }
    
    func parse(_ json: JsonWrapper, options: [Options]? = nil) {
        let dictionary = json.dictionary
        if dictionary.isEmpty { return }
        let relationships = options?.contains(.onlyAttributes) == true ? nil : entity.relationshipsByName
        parse(json: dictionary, attributes: entity.attributesByName, relationships: relationships)
    }
    
    // MARK: - Private parsing
    
    private func parse(json: JsonDictionary, attributes: [String: NSAttributeDescription], relationships: [String: NSRelationshipDescription]?) {
        let changedKeys = getChangedKeys(json: json)
        for (key, wrapper) in json where changedKeys?.contains(key) != true {
            if let attributeValue = attributes[key] {
                parse(key: key, wrapper: wrapper, attributeValue: attributeValue)
            } else if let relationshipsValue = relationships?[key] {
                parse(key: key, wrapper: wrapper, relationshipsValue: relationshipsValue)
            }
        }
        jsonParsed()
    }
    
    private func getChangedKeys(json: JsonDictionary) -> Set<String>? {
        let map = JsonMetaMap(json, managedObject: self)
        manualSetValue(map: map)
        return map.changedKeys
    }
    
    // MARK: - Attributes
    
    private func parse(key: String, wrapper: JsonWrapper, attributeValue: NSAttributeDescription) {
        switch attributeValue.attributeType {
        case .stringAttributeType: tryToSet(wrapper.string, for: key)
        case .integer16AttributeType: tryToSet(wrapper.int16, for: key)
        case .integer32AttributeType: tryToSet(wrapper.int32, for: key)
        case .integer64AttributeType: tryToSet(wrapper.int64, for: key)
        case .floatAttributeType: tryToSet(wrapper.float, for: key)
        case .doubleAttributeType: tryToSet(wrapper.double, for: key)
        case .booleanAttributeType: tryToSet(wrapper.bool, for: key)
        case .dateAttributeType: tryToSet(wrapper.date, for: key)
        case .binaryDataAttributeType: tryToSet(wrapper.data, for: key)
        case .transformableAttributeType: tryToSetTransformable(wrapper.any, for: key)
        default: break
        }
    }
    
    private func tryToSet(_ value: Any?, for key: String) {
        guard let value = value else { return }
        setValue(value, forKey: key)
    }
    
    private func tryToSetTransformable(_ value: Any?, for key: String) {
        if let value = value, let stringType = objcCType(of: key, anyClass: classForCoder),
            let classType = NSClassFromString(stringType),
            (value as? NSObject)?.isKind(of: classType) == true {
            setValue(value, forKey: key)
        }
    }
    
    // MARK: - Relationships
    
    private func parse(key: String, wrapper: JsonWrapper, relationshipsValue: NSRelationshipDescription) {
        guard let destination = relationshipsValue.destinationEntity else { return }
        let attributes = destination.attributesByName
        let relationships = destination.relationshipsByName
        func parseDict(_ dict: JsonDictionary) -> NSManagedObject? {
            if dict.isEmpty { return nil }
            let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
            object.parse(json: dict, attributes: attributes, relationships: relationships)
            return object
        }
        if relationshipsValue.isToMany {
            var objects = [NSManagedObject]()
            for wrapper in wrapper.array {
                guard let object = parseDict(wrapper.dictionary) else { continue }
                objects.append(object)
            }
            switch relationshipsValue.isOrdered {
            case true: mutableOrderedSetValue(forKey: key).addObjects(from: objects)
            case false: mutableSetValue(forKey: key).addObjects(from: objects)
            }
        } else if let object = parseDict(wrapper.dictionary) {
            setValue(object, forKey: key)
        }
    }
    
    // MARK: - Transformable
    
    private func objcCType(of key: String, anyClass: AnyClass) -> String? {
        var count = UInt32()
        guard let properties = class_copyPropertyList(anyClass, &count) else { return nil }
        var result: String?
        for i in 0..<Int(count) {
            guard let property = properties[i],
                let name = NSString(utf8String: property_getName(property)), String(name) == key
                else { continue }
            guard let attributes = NSString(utf8String: property_getAttributes(property))
                else { break }
            let slices = attributes.components(separatedBy: "\"")
            if slices.count > 1 {
                result = slices[1]
            } else if attributes.length > 1 {
                switch attributes.substring(with: NSRange(location: 1, length: 1)) {
                case "c": result = "Int8"
                case "s": result = "Int16"
                case "i": result = "Int32"
                case "q": result = "Int"
                case "S": result = "UInt16"
                case "I": result = "UInt32"
                case "Q": result = "UInt"
                case "B": result = "Bool"
                case "d": result = "Double"
                case "f": result = "Float"
                case "{": result = "Decimal"
                default: break
                }
            }
            break
        }
        free(properties)
        if result == nil, let superclass = superclass as? NSManagedObject.Type {
            result = objcCType(of: key, anyClass: superclass)
        }
        return result
    }
    
    // MARK: - Delegate
    
    func manualSetValue(map: JsonMap) {}
    func jsonParsed() {}
    
}
