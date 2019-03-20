//
//  OtherExtensions.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

public extension vector_float2 {
    public func toCGPoint() -> CGPoint {
        return convertDouble2CGPoint(self)
    }
    
    public func toCGVector() -> CGVector {
        return convertDouble2CGVector(self)
    }
}

public extension Float {
    public func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

#if swift(>=4.2)
#else
//print("Hello, Swift 4!")

public extension Float {
public static func random(in range:ClosedRange<Float>) -> Float {
return randomInterval(min: range.lowerBound, max: range.upperBound, precision: 7) + range.lowerBound
}
}

public extension CGFloat {
public static func random(in range:ClosedRange<CGFloat>) -> CGFloat {
return randomInterval(min: range.lowerBound.toDouble(), max: range.upperBound.toDouble(), precision: 7).toCGFloat() + range.lowerBound
}
}

#endif

