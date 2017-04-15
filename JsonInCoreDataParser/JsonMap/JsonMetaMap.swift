//
//  JsonMapItem.swift
//  EasyEway
//
//  Created by Beloizerov on 17.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

final class JsonMetaMap: JsonMap {
    
    // MARK: - JsonWrapper
    
    override subscript(key: String) -> JsonMap? {
        guard let map = super[key] else { return nil }
        beginObservingKeys()
        return map
    }
    
    override subscript(position: Int) -> JsonMap {
        beginObservingKeys()
        return super[position]
    }
    
    // MARK: - Changed keys
    
    private var tempKeys: Set<String>?
    
    var changedKeys: Set<String>? {
        guard let keys = tempKeys else { return nil }
        if context == nil {
            removeObservers()
            return keys
        }
        return Set(managedObject.changedValues().keys).subtracting(keys)
    }
    
    private func beginObservingKeys() {
        if tempKeys != nil { return }
        if context == nil {
            tempKeys = []
            addObservers()
        } else {
            tempKeys = Set(managedObject.changedValues().keys)
        }
    }
    
    // MARK: - Observer
    
    private var observedKeys: Set<String>?
    
    private func addObservers() {
        let keys = managedObject.entity.propertiesByName.keys
        for key in keys {
            managedObject.addObserver(self, forKeyPath: key, options: .old, context: nil)
        }
        observedKeys = Set(keys)
    }
    
    private func removeObservers() {
        observedKeys?.forEach { managedObject.removeObserver(self, forKeyPath: $0) }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else { return }
        tempKeys?.insert(key)
    }
    
}
