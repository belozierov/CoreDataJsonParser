//
//  PropertiesParsing.swift
//  EasyEway
//
//  Created by Beloizerov on 19.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

// MARK: - Any

func <- <T>(left: inout T, right: Any?) {
    guard let right = right as? T else { return }
    left = right
}

func <- <T>(left: inout T?, right: Any?) {
    guard let right = right as? T else { return }
    left = right
}

// MARK: - JsonWrapper

func <- <T>(left: inout T, right: JsonWrapper?) {
    guard let right = right?.any as? T else { return }
    left = right
}

func <- <T>(left: inout T?, right: JsonWrapper?) {
    guard let right = right?.any as? T else { return }
    left = right
}

// MARK: - SimpleInit

func <- <T: SimpleInit>(left: inout T, right: Any?) {
    guard let value = parse(any: right, to: T.self) else { return }
    left = value
}

func <- <T: SimpleInit>(left: inout T?, right: Any?) {
    guard let value = parse(any: right, to: T.self) else { return }
    left = value
}

private func parse<T: SimpleInit>(any: Any?, to type: T.Type) -> T? {
    if let value = any as? T {
        return value
    } else if let convertable = any as? JsonConvertable, let value = convertable.convert(to: type) {
        return value
    }
    return nil
}
