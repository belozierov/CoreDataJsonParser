//
//  JsonFunc.swift
//  EasyEway
//
//  Created by Beloizerov on 21.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

import Foundation

func json(_ any: Any) -> JsonWrapper {
    switch any {
    case let wrapper as JsonWrapper: return wrapper
    case let dictionary as [String: Any]: return JsonDictionary(dictionary)
    case let array as [Any]: return JsonArray(array)
    default: return JsonValue(any)
    }
}

func json(_ dictionary: [String: Any]) -> JsonWrapper {
    return JsonDictionary(dictionary)
}

func json(_ array: [Any]) -> JsonWrapper {
    return JsonArray(array)
}

func json(_ string: String) -> JsonWrapper {
    if JSONSerialization.isValidJSONObject(string),
        let data = string.data(using: .utf8) { return json(data) }
    else { return JsonValue(string) }
}

func json(_ data: Data) -> JsonWrapper {
    do { return json(try JSONSerialization.jsonObject(with: data, options: [.allowFragments])) }
    catch { return JsonValue() }
}
