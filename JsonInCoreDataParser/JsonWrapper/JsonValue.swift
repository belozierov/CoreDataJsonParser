//
//  JsonValue.swift
//  EasyEway
//
//  Created by Beloizerov on 13.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

struct JsonValue: JsonWrapper, JsonConvertable {
    
    let any: Any
    
    init(_ any: Any) {
        self.any = any
    }
    
}
