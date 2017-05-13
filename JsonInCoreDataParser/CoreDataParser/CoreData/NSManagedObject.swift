//
//  NSManagedObject.swift
//  JsonInCoreDataParser
//
//  Created by Beloizerov on 03.02.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

extension NSManagedObject {
    
    enum ParseOption {
        case onlyAttributes, dismissManualParsing
    }
    
    // MARK: - Public parsing
    
    func parse(_ any: Any, options: [ParseOption]? = nil) {
        switch any {
        case let data as Data: parse(json(data), options: options)
        case let string as String: parse(json(string), options: options)
        default: parse(json(any), options: options)
        }
    }
    
    func parse(_ json: JsonWrapper, options: [ParseOption]? = nil) {
        if json.isEmpty { return }
        let relationships = options?.contains(.onlyAttributes) == true ? nil : entity.relationshipsByName
        let manualParse = options?.contains(.dismissManualParsing) != true
        parse(dictionary: json.dictionary, attributes: entity.attributesByName, relationships: relationships, manualParse: manualParse)
    }
    
    func parsed(_ any: Any, options: [ParseOption]? = nil) -> Self {
        parse(any, options: options)
        return self
    }
    
    func parsed(_ wrapper: JsonWrapper, options: [ParseOption]? = nil) -> Self {
        parse(wrapper, options: options)
        return self
    }
    
    // MARK: - Private parsing
    
    private func parse(dictionary: JsonDictionary, attributes: [String: NSAttributeDescription], relationships: [String: NSRelationshipDescription]?, manualParse: Bool) {
        let changedKeys = manualParse ? getChangedKeys(dictionary: dictionary): nil
        for (key, wrapper) in dictionary where changedKeys?.contains(key) != true {
            if let attributeValue = attributes[key] {
                parse(key: key, wrapper: wrapper, attributeValue: attributeValue)
            } else if let relationshipsValue = relationships?[key] {
                parse(key: key, wrapper: wrapper, relationshipsValue: relationshipsValue, manualParse: manualParse)
            }
        }
        jsonParsed()
    }
    
    private func getChangedKeys(dictionary: JsonDictionary) -> Set<String>? {
        let map = JsonMetaMap(dictionary, managedObject: self, parseOptions: nil)
        manualSetValue(map: map)
        return map.changedKeys
    }
    
    // MARK: - Attributes parsing
    
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
        case .transformableAttributeType: tryToSetTransformable(wrapper.any, for: key)
        default: break
        }
    }
    
    private func tryToSet(_ value: Any?, for key: String) {
        guard let value = value else { return }
        setValue(value, forKey: key)
    }
    
    private func tryToSetTransformable(_ value: Any?, for key: String) {
        if let value = value as? NSObject,
            let stringType = objcCType(of: key, anyClass: classForCoder),
            let classType = NSClassFromString(stringType), value.isKind(of: classType) {
            setValue(value, forKey: key)
        }
    }
    
    // MARK: - Relationships parsing
    
    private func parse(key: String, wrapper: JsonWrapper, relationshipsValue: NSRelationshipDescription, manualParse: Bool) {
        guard let entity = relationshipsValue.destinationEntity else { return }
        let attributes = entity.attributesByName
        let relationships = entity.relationshipsByName
        func parseDict(_ dict: JsonDictionary) -> NSManagedObject? {
            if dict.isEmpty { return nil }
            let object = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            object.parse(dictionary: dict, attributes: attributes, relationships: relationships, manualParse: manualParse)
            return object
        }
        if relationshipsValue.isToMany {
            var objects = [NSManagedObject]()
            objects.reserveCapacity(wrapper.count)
            for wrapper in wrapper.array {
                guard let object = parseDict(wrapper.dictionary) else { continue }
                objects.append(object)
            }
            if objects.isEmpty { return }
            switch relationshipsValue.isOrdered {
            case true: mutableOrderedSetValue(forKey: key).addObjects(from: objects)
            case false: mutableSetValue(forKey: key).addObjects(from: objects)
            }
        } else if let object = parseDict(wrapper.dictionary) {
            setValue(object, forKey: key)
        }
    }
    
    // MARK: - Transformable parsing
    
    private func objcCType(of key: String, anyClass: AnyClass) -> String? {
        guard let property = class_getProperty(anyClass, key.cString(using: .utf8)) else {
            guard let superclass = anyClass.superclass() as? NSManagedObject.Type else { return nil }
            return objcCType(of: key, anyClass: superclass)
        }
        let attributes = String(cString: property_getAttributes(property))
        guard attributes.characters.count > 1 else { return nil }
        do {
            let slices = attributes.components(separatedBy: "\"")
            if slices.count > 1 { return slices[1] }
        }
        switch attributes[attributes.index(attributes.startIndex, offsetBy: 1)] {
        case "c": return "Int8"
        case "s": return "Int16"
        case "i": return "Int32"
        case "q": return "Int"
        case "S": return "UInt16"
        case "I": return "UInt32"
        case "Q": return "UInt"
        case "B": return "Bool"
        case "d": return "Double"
        case "f": return "Float"
        case "{": return "Decimal"
        default: return nil
        }
    }
    
    // MARK: - Delegate
    
    func manualSetValue(map: JsonMap) {}
    func jsonParsed() {}
    
}
