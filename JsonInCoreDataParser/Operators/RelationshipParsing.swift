//
//  RelationshipParsing.swift
//  EasyEway
//
//  Created by Beloizerov on 19.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import CoreData

func <- (left: NSManagedObject, right: Any?) {
    guard let right = right else { return }
    left.parse(right)
}

func <- <T: NSManagedObject>(left: inout T?, right: JsonMap?) {
    guard let map = right, let entity = entityDescription(map: map, type: T.self) else { return }
    left = T(entity: entity, insertInto: map.context).parsed(map.wrapper)
}

func <- <T: NSManagedObject>(left: inout Set<T>?, right: JsonMap?) {
    guard let map = right else { return }
    var set = Set<T>()
    parse(set: &set, map: map)
    left = set
}

func <- <T: NSManagedObject>(left: inout [T]?, right: JsonMap?) {
    guard let map = right else { return }
    var array = [T]()
    parse(array: &array, map: map)
    left = array
}

// MARK: - iOS 9

func <- <T: NSManagedObject>(left: inout NSSet?, right: (map: JsonMap?, type: T.Type)) {
    guard let map = right.map else { return }
    var set = Set<T>()
    parse(set: &set, map: map)
    if let leftSet = left {
        let mutableSet = NSMutableSet(set: leftSet)
        mutableSet.addingObjects(from: set)
        left = mutableSet
    } else {
        left = NSSet(set: set)
    }
}

func <- <T: NSManagedObject>(left: inout NSOrderedSet?, right: (map: JsonMap?, type: T.Type)) {
    guard let map = right.map else { return }
    var array = [T]()
    parse(array: &array, map: map)
    if let leftArray = left {
        let mutableSet = NSMutableOrderedSet(orderedSet: leftArray)
        mutableSet.addObjects(from: array)
        left = mutableSet
    } else {
        left = NSMutableOrderedSet(array: array)
    }
}

// MARK: - Private metodes

private func parse<T: NSManagedObject>(set: inout Set<T>, map: JsonMap) {
    guard let entity = entityDescription(map: map, type: T.self) else { return }
    for json in map.array {
        set.insert(T(entity: entity, insertInto: map.context).parsed(json))
    }
}

private func parse<T: NSManagedObject>(array: inout [T], map: JsonMap) {
    guard let entity = entityDescription(map: map, type: T.self) else { return }
    for json in map.array {
        array.append(T(entity: entity, insertInto: map.context).parsed(json))
    }
}

private func entityDescription<T: NSManagedObject>(map: JsonMap, type: T.Type) -> NSEntityDescription? {
    if #available(iOS 10.0, *) {
        return T.entity()
    } else {
        let name = String(describing: type)
        return map.managedObject.entity.managedObjectModel.entitiesByName[name]
    }
}
