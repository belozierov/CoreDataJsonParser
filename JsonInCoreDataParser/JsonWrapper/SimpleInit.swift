//
//  SimpleInit.swift
//  EasyEway
//
//  Created by Beloizerov on 14.02.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

protocol SimpleInit {
    
    init?(string: String)
    init?(number: NSNumber)
    
}

extension String: SimpleInit {
    
    init?(string: String) {
        self = string
    }
    
    init?(number: NSNumber) {
        self = number.stringValue
    }
    
}

extension Bool: SimpleInit {
    
    init?(string: String) {
        if let value = Bool(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.boolValue
    }
    
}

extension Int: SimpleInit {
    
    init?(string: String) {
        if let value = Int(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.intValue
    }
    
}

extension Int16: SimpleInit {
    
    init?(string: String) {
        if let value = Int16(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.int16Value
    }
    
}

extension Int32: SimpleInit {
    
    init?(string: String) {
        if let value = Int32(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.int32Value
    }
    
}

extension Int64: SimpleInit {
    
    init?(string: String) {
        if let value = Int64(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.int64Value
    }
    
}

extension Float: SimpleInit {
    
    init?(string: String) {
        if let value = Float(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.floatValue
    }
    
}

extension Double: SimpleInit {
    
    init?(string: String) {
        if let value = Double(string) { self = value }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = number.doubleValue
    }
    
}

extension Date: SimpleInit {
    
    init?(string: String) {
        if let time = TimeInterval(string) { self = Date(timeIntervalSince1970: time) }
        else { return nil }
    }
    
    init?(number: NSNumber) {
        self = Date(timeIntervalSince1970: number.doubleValue)
    }
    
}
