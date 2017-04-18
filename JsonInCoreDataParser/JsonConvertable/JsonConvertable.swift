//
//  JsonConvertable.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

protocol JsonConvertable {
    
    func converted<T: SimpleInit>() -> T?
    
}

extension JsonConvertable {
    
    fileprivate func _convert<T: SimpleInit>(any: Any?) -> T? {
        switch any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }
    
}

extension JsonConvertable where Self: JsonWrapper {
    
    func converted<T: SimpleInit>() -> T? {
        return _convert(any: any)
    }
    
}

extension JsonConvertable where Self: Collection, Self.Iterator.Element == JsonWrapper {
    
    func converted<T: SimpleInit>() -> T? {
        guard count == 1 else { return nil }
        return _convert(any: first?.any)
    }

}
