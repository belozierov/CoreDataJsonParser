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
    
    // MARK: - Private parsing
    
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
    
    // MARK: - Properties parsing
    
    private func parse(json: JsonDictionary, attributes: [String: NSAttributeDescription]?, relationships: [String: NSRelationshipDescription]?) {
        let changedKeys = getChangedKeys(json: json)
        for (key, json) in json where changedKeys?.contains(key) != true {
            if let attributeValue = attributes?[key] {
                parse(key: key, node: json, attributeValue: attributeValue)
            } else if let relationshipsValue = relationships?[key] {
                parse(key: key, node: json, relationshipsValue: relationshipsValue)
            }
        }
        jsonParsed()
    }
    
    private func getChangedKeys(json: JsonDictionary) -> Set<String>? {
        let map = JsonMetaMap(json, managedObject: self)
        manualSetValue(map: map)
        return map.changedKeys
    }
    
    private func parse(key: String, node: JsonWrapper, attributeValue: NSAttributeDescription) {
        switch attributeValue.attributeType {
        case .stringAttributeType: tryToSetValue(node.string, for: key)
        case .integer16AttributeType: tryToSetValue(node.int16, for: key)
        case .integer32AttributeType: tryToSetValue(node.int32, for: key)
        case .integer64AttributeType: tryToSetValue(node.int64, for: key)
        case .floatAttributeType: tryToSetValue(node.float, for: key)
        case .doubleAttributeType: tryToSetValue(node.double, for: key)
        case .booleanAttributeType: tryToSetValue(node.bool, for: key)
        case .dateAttributeType: tryToSetValue(node.date, for: key)
        case .binaryDataAttributeType: tryToSetValue(node.data, for: key)
        default: break
        }
    }
    
    private func parse(key: String, node: JsonWrapper, relationshipsValue: NSRelationshipDescription) {
        if let destination = relationshipsValue.destinationEntity {
            let attributes = destination.attributesByName
            let relationships = destination.relationshipsByName
            if relationshipsValue.isToMany {
                if let dictionary = node.dictionary {
                    let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                    object.parse(json: dictionary, attributes: attributes, relationships: relationships)
                    switch relationshipsValue.isOrdered {
                    case true: mutableOrderedSetValue(forKey: key).add(object)
                    case false: mutableSetValue(forKey: key).add(object)
                    }
                } else if let array = node.array {
                    let isOrdered = relationshipsValue.isOrdered
                    for node in array {
                        if let dict = node.dictionary {
                            let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                            object.parse(json: dict, attributes: attributes, relationships: relationships)
                            switch isOrdered {
                            case true: mutableOrderedSetValue(forKey: key).add(object)
                            case false: mutableSetValue(forKey: key).add(object)
                            }
                        }
                    }
                }
            } else if let dict = node.dictionary ?? node.first?.dictionary {
                let object = NSManagedObject(entity: destination, insertInto: managedObjectContext)
                object.parse(json: dict, attributes: attributes, relationships: relationships)
                setValue(object, forKey: key)
            }
        }
    }
    
    private func tryToSetValue(_ value: Any?, for key: String) {
        guard let value = value else { return }
        setValue(value, forKey: key)
    }
    
    // MARK: - setValues
    
    func manualSetValue(map: JsonMap) {}
    func jsonParsed() {}
    
}
