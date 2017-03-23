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
    
    func parse(_ any: Any, options: [Options] = []) {
        switch any {
        case let data as Data: parse(json(data), options: options)
        case let string as String: parse(json(string), options: options)
        default: parse(json(any), options: options)
        }
    }
    
    func parsed(_ any: Any, options: [Options] = []) -> Self {
        parse(any, options: options)
        return self
    }
    
    func parse(_ string: String, options: [Options] = []) {
        parse(json(string), options: options)
    }
    
    func parse(_ data: Data, options: [Options] = []) {
        parse(json(data), options: options)
    }
    
    func parse(_ dict: [String: Any], options: [Options] = []) {
        let relationships = options.contains(.onlyAttributes) ? nil : entity.relationshipsByName
        parse(json: JsonDictionary(dict), attributes: entity.attributesByName, relationships: relationships)
    }
    
    func parse(_ json: JsonWrapper, options: [Options] = []) {
        guard let dictionary = json.dictionary ?? json.first?.dictionary else { return }
        let relationships = options.contains(.onlyAttributes) ? nil : entity.relationshipsByName
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
    
    private func tryToSetTransformable(_ value: Any, for key: String) {
        guard let stringType = objcCType(of: key),
            let classType = NSClassFromString(stringType),
            (value as? NSObject)?.isKind(of: classType) == true
            else { return }
        debugPrint("good")
        setValue(value, forKey: key)
    }
    
    // MARK: - Relationships
    
    private func parse(key: String, wrapper: JsonWrapper, relationshipsValue: NSRelationshipDescription) {
        if let destination = relationshipsValue.destinationEntity {
            let attributes = destination.attributesByName
            let relationships = destination.relationshipsByName
            if relationshipsValue.isToMany {
                if let dictionary = wrapper.dictionary {
                    let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                    object.parse(json: dictionary, attributes: attributes, relationships: relationships)
                    switch relationshipsValue.isOrdered {
                    case true: mutableOrderedSetValue(forKey: key).add(object)
                    case false: mutableSetValue(forKey: key).add(object)
                    }
                } else if let array = wrapper.array {
                    var objects = [NSManagedObject]()
                    for wrapper in array {
                        guard let dict = wrapper.dictionary else { continue }
                        let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                        object.parse(json: dict, attributes: attributes, relationships: relationships)
                        objects.append(object)
                    }
                    switch relationshipsValue.isOrdered {
                    case true: mutableOrderedSetValue(forKey: key).addObjects(from: objects)
                    case false: mutableSetValue(forKey: key).addObjects(from: objects)
                    }
                }
            } else if let dict = wrapper.dictionary ?? wrapper.first?.dictionary {
                let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                object.parse(json: dict, attributes: attributes, relationships: relationships)
                setValue(object, forKey: key)
            }
        }
    }
    
    // MARK: - Transformable
    
    private func objcCType(of key: String) -> String? {
        var count = UInt32()
        guard let properties = class_copyPropertyList(classForCoder, &count) else { return nil }
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
        return result
    }
    
    // MARK: - Delegate
    
    func manualSetValue(map: JsonMap) {}
    func jsonParsed() {}
    
}
