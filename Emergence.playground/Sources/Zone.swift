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
//        print(self.canvas.minX, self.canvas.minY)
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
    
    
    /// Generate every single dark sprite.
    /// WARNIN: This function must be run after the rect of the zone has been computed
    ///
    /// - Returns: A list of dark sprites of the edges from the actual zone
    public func generateDarkSprites(wallborder: CGFloat) -> [SKSpriteNode] {
        var shapes:[SKSpriteNode] = []
        var darkEdges:[ZoneSide: [EdgePair]] = [:]
        
        let sides = [ZoneSide.bottom, ZoneSide.top, ZoneSide.right, ZoneSide.left]
        
        //------------------------------------------------
        // Computes every single dark edge for every side
        for side in sides {
            let startX = self.computedRect.minX
            let endX = self.computedRect.maxX
            let startY = self.computedRect.minY
            let endY = self.computedRect.maxY
            var startPt = startX
            var endPt = endX
            var st_dark:Bool = false
            var is_dark = true
            
            var pt0:CGFloat = 0
            var pt1:CGFloat = 0
            
            // Traverse over x axys (default)
            if side == .bottom || side == .top {}
            
            // Traverse over y axys
            if side == .right || side == .left {
                startPt = startY
                endPt = endY
            }
            
            // Traverse every point in the edge
            for pt in Int(startPt)...Int(endPt) {
                let edges = self.allowedEdges[side] ?? []
                
                //------------------------------------------------
                // Check if the actual point is dark
                is_dark = true
                for edge in edges {
//                    print("* ", pt, edge.contains(position: CGFloat(pt)), st_dark)
                    if edge.contains(position: CGFloat(pt)) {
                        is_dark = false
                        break // breaks to enhance performance
                    }
                }
                
                //------------------------------------------------
                // Verify if we were in a trail of white points
                if !st_dark {
                    if is_dark {
//                        print("-> ", side, pt1, pt0)
                        st_dark = true
                        pt0 = CGFloat(pt)
                    }
                }
                else {
                    pt1 = CGFloat(pt)
                    if !is_dark {
//                        print(side, pt1, pt0)
                        st_dark = false
                        
                        let edge = EdgePair(begin: pt0, length: abs(pt1 - pt0))
                        darkEdges[side] = (darkEdges[side] ?? []) + [edge]
                    }
                }
            }
            
            // Add the last dark border if and only if the first script has run
            if st_dark {
//                print(side, pt1, pt0)
                let edge = EdgePair(begin: pt0, length: abs(pt1 - pt0))
                darkEdges[side] = (darkEdges[side] ?? []) + [edge]
            }
        }
        
        //------------------------------------------------
        // Compute the shapes based in the dark edges
        for side in sides {
            let edges = darkEdges[side] ?? []
            print(side, edges)
            for edge in edges {
                let center = (2*edge.begin + edge.length)/2
                var centerX:CGFloat = 0
                var centerY:CGFloat = 0
                var width:CGFloat = 0
                var height:CGFloat = 0
                
                print("->", side, edge)
                
                // Align the node in the center
                if side == .bottom {
                    centerY = self.computedRect.minY + wallborder/2
                    centerX = center
                    width = edge.length
                    height = wallborder
                }
                if side == .top {
                    centerY = self.computedRect.maxY - wallborder/2
                    centerX = center
                    width = edge.length
                    height = wallborder
                }
                if side == .right {
                    centerY = center
                    centerX = self.computedRect.maxX - wallborder/2
                    width = wallborder
                    height = edge.length
                }
                if side == .left {
                    centerY = center
                    centerX = self.computedRect.minX + wallborder/2
                    width = wallborder
                    height = edge.length
                }
                
                let node = SKSpriteNode(color: .black, size: CGSize(width: width, height: height))
                node.position = CGPoint(x: centerX, y: centerY)
                node.zPosition = 30
                shapes.append(node)
            }
        }
        
        
        return shapes
    }
    
}


public class Scenario {
    var zones:[Zone] = []
    
    init(zones:[Zone]) {
        self.zones = zones
    }
}
