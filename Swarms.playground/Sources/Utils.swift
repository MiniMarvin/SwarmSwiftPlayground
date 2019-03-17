//
//  Utils.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: Enums

public enum Errors:Error {
    case runtimeError(String)
}

// MARK: Conversion Functions

public func convertDouble2CGVector(_ value:vector_double2) -> CGVector {
    return CGVector(dx: CGFloat(value.x), dy: CGFloat(value.y))
}

public func convertCGVector2Double(_ value: CGVector) -> vector_double2 {
    return vector_double2(Double(value.dx), Double(value.dy))
}

public func convertDouble2CGPoint(_ value:vector_double2) -> CGPoint {
    return CGPoint(x: CGFloat(value.x), y: CGFloat(value.y))
}

public func convertCGPoint2Double(_ value:CGPoint) -> vector_double2 {
    return vector_double2(x: Double(value.x), y: Double(value.y))
}

// MARK: Random Functions

public func randomDoublesVector(max:Double) -> [Double] {
    var f = Double(randomInterval(min: 0, max: max, precision: 5))
    var t = sqrt(max*max - f*f)
    
    if (randomInterval(min: 0, max: 1, precision: 5)) > 0.5 { f *= -1 }
    if (randomInterval(min: 0, max: 1, precision: 5)) > 0.5 { t *= -1 }
    
    return [f, t]
}

public func randomDoubles(min:Double, max:Double, n:Int) -> [Double] {
    var arr:[Double] = []
    for _ in 0...(n-1) {
        let a:Double = Double(randomInterval(min: min, max: max, precision: 5))
        arr.append(a)
    }
    return arr
}

public func randomInterval(min:Double, max:Double, precision:Int) -> Double {
    var m:Int = 1
    for _ in 1...precision {
        m *= 10
    }
    let r = (max - min)*Double(arc4random()%(UInt32(m) + UInt32(1)))/Double(m)
    return r
}

