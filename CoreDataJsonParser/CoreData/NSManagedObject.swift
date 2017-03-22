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
        case .stringAttributeType: tryToSetValue(wrapper.string, for: key)
        case .integer16AttributeType: tryToSetValue(wrapper.int16, for: key)
        case .integer32AttributeType: tryToSetValue(wrapper.int32, for: key)
        case .integer64AttributeType: tryToSetValue(wrapper.int64, for: key)
        case .floatAttributeType: tryToSetValue(wrapper.float, for: key)
        case .doubleAttributeType: tryToSetValue(wrapper.double, for: key)
        case .booleanAttributeType: tryToSetValue(wrapper.bool, for: key)
        case .dateAttributeType: tryToSetValue(wrapper.date, for: key)
        case .binaryDataAttributeType: tryToSetValue(wrapper.data, for: key)
        default: break
        }
    }
    
    private func tryToSetValue(_ value: Any?, for key: String) {
        guard let value = value else { return }
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
                    let isOrdered = relationshipsValue.isOrdered
                    for wrapper in array {
                        if let dict = wrapper.dictionary {
                            let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                            object.parse(json: dict, attributes: attributes, relationships: relationships)
                            switch isOrdered {
                            case true: mutableOrderedSetValue(forKey: key).add(object)
                            case false: mutableSetValue(forKey: key).add(object)
                            }
                        }
                    }
                }
            } else if let dict = wrapper.dictionary ?? wrapper.first?.dictionary {
                let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                object.parse(json: dict, attributes: attributes, relationships: relationships)
                setValue(object, forKey: key)
            }
        }
    }
    
    // MARK: - Delegate
    
    func manualSetValue(map: JsonMap) {}
    func jsonParsed() {}
    
}
