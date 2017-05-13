//
//  JsonValue.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

struct JsonValue: JsonWrapper {
    
    let any: Any?
    init(_ any: Any? = nil) { self.any = any }
    
    // MARK: - JsonWrapper
    
    var isEmpty: Bool { return any == nil }
    var count: Int { return isEmpty ? 0 : 1 }
    
}
