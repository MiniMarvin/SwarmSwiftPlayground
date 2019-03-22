//
//  Zones.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 19/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

public enum ZoneSide {
    case left
    case right
    case top
    case bottom
}

public struct EdgePair {
    var begin:CGFloat
    var length:CGFloat
    
    init(begin:CGFloat, length:CGFloat) {
        self.begin = begin
        self.length = length
    }
    
    func contains(position:CGFloat) -> Bool {
        return position < self.begin + self.length && position > self.begin
    }
}

public class Zone: NSObject {
    public var widthFraction:CGFloat
    public var startFractionX:CGFloat
    public var heightFraction:CGFloat
    public var startFractionY:CGFloat
    public var allowedEdgesFractions:[ZoneSide: [EdgePair]]
    public var allowedEdges:[ZoneSide: [EdgePair]] = [:]
    public var computedRect: CGRect = CGRect()
    public var canvas:CGRect
    
    public init(startFractionX: CGFloat, startFractionY: CGFloat, widthFraction: CGFloat, heightFraction: CGFloat, canvas:CGRect, allowedEdgesFractions:[ZoneSide: [EdgePair]]) {
        
        self.startFractionX = startFractionX
        self.startFractionY = startFractionY
        self.widthFraction = widthFraction
        self.heightFraction = heightFraction
        if startFractionX + widthFraction > 1 {
            self.widthFraction = 1 - startFractionX
        }
        if startFractionY + heightFraction > 1 {
            self.heightFraction = 1 - startFractionY
        }
        self.allowedEdgesFractions = allowedEdgesFractions
        self.canvas = canvas
        
        super.init()
        
        self.buildScenarioRect()
    }
    
    convenience init(startFractionX:CGFloat, endFractionX:CGFloat, startFractionY:CGFloat, endFractionY:CGFloat,canvas:CGRect, allowedEdgesFractions:[ZoneSide: [EdgePair]]) {
        let widthFraction = endFractionX - startFractionX
        let heightFraction = endFractionY - startFractionY
        
        self.init(startFractionX: startFractionX, startFractionY: startFractionY, widthFraction: widthFraction, heightFraction: heightFraction, canvas: canvas, allowedEdgesFractions: allowedEdgesFractions)
    }
    
    public func buildScenarioRect() {
        let startX = self.startFractionX*self.canvas.width
        let startY = self.startFractionY*self.canvas.height
        let width = self.widthFraction*self.canvas.width
        let height = self.heightFraction*self.canvas.height
        print(self.canvas.minX, self.canvas.minY)
        let x = self.canvas.minX + startX
        let y = self.canvas.minY + startY
        self.computedRect = CGRect(x: x, y: y, width: width, height: height)
        
        let bottom = self.allowedEdgesFractions[.bottom] ?? []
        self.allowedEdges[.bottom] = bottom.flatMap({ pair in
            return EdgePair(begin: pair.begin*width + x, length: pair.length*width)
        })
        
        let top = self.allowedEdgesFractions[.top] ?? []
        self.allowedEdges[.top] = top.flatMap({ pair in
            return EdgePair(begin: pair.begin*width + x, length: pair.length*width)
        })
        
        let right = self.allowedEdgesFractions[.right] ?? []
        self.allowedEdges[.right] = right.flatMap({ pair in
            return EdgePair(begin: pair.begin*height + y, length: pair.length*height)
        })
        
        let left = self.allowedEdgesFractions[.left] ?? []
        self.allowedEdges[.left] = left.flatMap({ pair in
            return EdgePair(begin: pair.begin*height + y, length: pair.length*height)
        })
    }
    
    public func isInside(point:CGPoint) {
        self.computedRect.contains(point)
    }
    
    // TODO: Build the dark sprites in the scene
    
    public func generateDarkSprites() -> [SKShapeNode] {
        var shapes:[SKShapeNode] = []
        
        
        return shapes
    }
    
}


public class Scenario {
    var zones:[Zone] = []
    
    init(zones:[Zone]) {
        self.zones = zones
    }
}
