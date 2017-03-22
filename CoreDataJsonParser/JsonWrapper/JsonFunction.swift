//
//  JsonFunc.swift
//  EasyEway
//
//  Created by Beloizerov on 21.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

func json(_ any: Any) -> JsonWrapper {
    switch any {
    case let dictionary as [String: Any]: return JsonDictionary(dictionary)
    case let array as [Any]: return JsonArray(array)
    case let wrapper as JsonWrapper: return wrapper
    default: return JsonValue(any)
    }
}

func json(_ dictionary: [String: Any]) -> JsonWrapper {
    return JsonDictionary(dictionary)
}

func json(_ array: [Any]) -> JsonWrapper {
    return JsonArray(array)
}

