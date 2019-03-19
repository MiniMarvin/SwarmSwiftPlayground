//
//  OtherExtensions.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

extension vector_float2 {
    func toCGPoint() -> CGPoint {
        return convertDouble2CGPoint(self)
    }
    
    func toCGVector() -> CGVector {
        return convertDouble2CGVector(self)
    }
}

extension Float {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}
