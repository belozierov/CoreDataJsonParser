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
    guard let value: T = convert(any: right) else { return }
    left = value
}

func <- <T: SimpleInit>(left: inout T?, right: Any?) {
    guard let value: T = convert(any: right) else { return }
    left = value
}

func <- <T: SimpleInit>(left: inout T, right: JsonWrapper?) {
    guard let value: T = convert(any: right) else { return }
    left = value
}

func <- <T: SimpleInit>(left: inout T?, right: JsonWrapper?) {
    guard let value: T = convert(any: right) else { return }
    left = value
}

private func convert<T: SimpleInit>(any: Any?) -> T? {
    return any as? T ?? (any as? JsonConvertable)?.converted()
}
