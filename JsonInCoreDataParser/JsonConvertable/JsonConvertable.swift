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
    func converted<T: SimpleInit>() -> T?
    
}

extension JsonConvertable {
    
    func converted<T: SimpleInit>() -> T? {
        switch any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }
    
}

extension JsonConvertable where Self: JsonCollectionWrapper {
    
    func converted<T: SimpleInit>() -> T? {
        switch first?.any {
        case let t as T: return t
        case let string as String: return T(string: string)
        case let number as NSNumber: return T(number: number)
        default: return nil
        }
    }

}
