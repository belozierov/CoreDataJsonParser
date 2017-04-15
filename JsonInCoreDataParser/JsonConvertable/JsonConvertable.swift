//
//  JsonConvertable.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

protocol JsonConvertable {
    
    var any: Any { get }
    func convert<T: SimpleInit>(to type: T.Type) -> T?
    func convert<T: SimpleInit>(to type: T?.Type) -> T?
    
}

extension JsonConvertable {
    
    func convert<T: SimpleInit>(to type: T.Type) -> T? {
        switch any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }
    
    func convert<T: SimpleInit>(to type: T?.Type) -> T? {
        return convert(to: T.self)
    }
    
}

extension JsonConvertable where Self: JsonCollectionWrapper {
    
    func convert<T: SimpleInit>(to type: T.Type) -> T? {
        switch first?.any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }
    
    func convert<T: SimpleInit>(to type: T?.Type) -> T? {
        return convert(to: T.self)
    }
    
}
