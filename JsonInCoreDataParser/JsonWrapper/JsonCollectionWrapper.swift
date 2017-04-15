//
//  JsonCollectionWrapper.swift
//  EasyEway
//
//  Created by Beloizerov on 15.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

protocol JsonCollectionWrapper: JsonWrapper, Collection {}

extension JsonCollectionWrapper {
    
    var string: String? { return first?.string }
    var bool: Bool? { return first?.bool }
    var int: Int? { return first?.int }
    var int16: Int16? { return first?.int16 }
    var int32: Int32? { return first?.int32 }
    var int64: Int64? { return first?.int64 }
    var float: Float? { return first?.float }
    var double: Double? { return first?.double }
    var date: Date? { return first?.date }
    var data: Data? { return first?.data }
    
}
