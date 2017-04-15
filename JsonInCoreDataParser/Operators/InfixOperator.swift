//
//  InfixOperator.swift
//  EasyEway
//
//  Created by Beloizerov on 19.03.17.
//  Copyright © 2017 Beloizerov. All rights reserved.
//

infix operator <-: MultiplicationPrecedence
precedencegroup MultiplicationPrecedence {
    associativity: right
    lowerThan: NilCoalescingPrecedence
}
