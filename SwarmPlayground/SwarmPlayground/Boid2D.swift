//
//  Agent.swift
//  SwarmPlayground
//
//  Created by Caio Gomes on 16/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//


// TODO: Insert Metal
import Foundation
import SpriteKit

public class Boid2D: NSObject {
    
    public var baseNode:SKSpriteNode
    // TODO: add a 3d vector
    public var position:vector_double2
    public var velocity:vector_double2
    public var acceleration:vector_double2
    public var id:Int = 0
    public var category:Int = 0
    public var neightBoorHood:[Boid2D]
    public var neightBoorHoodSize:Double
    
    public var radius: Double = 10
    public var currentSpeed: Double = 0
    
    public override init() {
        // Setup a physics body
        let texture = SKTexture(imageNamed: "play-arrow.png")
        self.baseNode = SKSpriteNode(texture: texture)
        self.baseNode.size = CGSize(width: self.radius, height: self.radius)
        self.baseNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.radius, height: self.radius))
        self.baseNode.physicsBody?.affectedByGravity = false
        self.baseNode.physicsBody?.collisionBitMask = 0
        self.baseNode.physicsBody?.contactTestBitMask = 0
        self.baseNode.physicsBody?.isDynamic = true
        self.baseNode.physicsBody?.allowsRotation = false
        self.baseNode.physicsBody?.mass = 1
        self.baseNode.physicsBody?.friction = 0
        
        let mx:Double = 10.0
        let wx:Double = 100.0
        self.position = vector_double2(randomDoublesVector(max: wx))
        self.velocity = vector_double2(randomDoublesVector(max: mx))
        self.acceleration = vector_double2([Double].init(repeating: 0, count: 2))
        self.neightBoorHood = []
        self.neightBoorHoodSize = 10
        
        super.init()
        self.setPosition()
    }
    
    public func setPosition() {
        self.baseNode.position = convertDouble2CGPoint(self.position)
    }
    
    public func setProperties() {
        self.baseNode.physicsBody?.velocity = convertDouble2CGVector(self.velocity)
        // Update rotation
        let x = self.baseNode.physicsBody?.velocity.dx
        let y = self.baseNode.physicsBody?.velocity.dy
        self.baseNode.zRotation = atan2(x!, y!)
    }
    
    public func isNeightBoor(to node:Boid2D) -> Bool {
        if node.id == self.id { return false }
        let p1:vector_double2 = convertCGPoint2Double(self.baseNode.position)
        let p2:vector_double2 = convertCGPoint2Double(node.baseNode.position)
        
        // TODO: Add the angular visibility
        if simd_distance(p1, p2) < self.neightBoorHoodSize {
            return true
        }
        
        return false
    }
    
    public func getNeightBoors(_ nodes: [Boid2D]) -> [Boid2D] {
        return nodes.filter({boid in
            return self.isNeightBoor(to: boid)
        })
    }
    
    public func align(neightBoorHood:[Boid2D]) -> vector_double2 {
        var avg = vector_double2([Double].init(repeating: 0.0, count: 2))
        let neightboors = self.getNeightBoors(neightBoorHood)
        
        neightboors.forEach({node in
            avg += convertCGVector2Double((node.baseNode.physicsBody?.velocity)!)
        })
        
        avg /= Double(neightboors.count)
        
        // Automatically iterate in the boid
        return avg - self.velocity
    }
    
    public func alignProperly(neightBoorHood:[Boid2D], maxMagnetude:Double) {
        var force = self.align(neightBoorHood: neightBoorHood)
        let magnetude = simd_length(force)
        if magnetude > maxMagnetude {force *= (maxMagnetude/magnetude)}
        self.acceleration = force
    }
    
    
    public func adjustPosition(canvas:CGRect) {
        var base = false
        let offset:CGFloat = 1
        self.position.x = Double(self.baseNode.position.x)
        self.position.y = Double(self.baseNode.position.y)
        
        if self.baseNode.position.x > canvas.width/2 {
            self.position.x = Double(-canvas.height/2 + offset)
            self.position.y *= -1
            base = true
        }
        if self.baseNode.position.x < -canvas.width/2 {
            self.position.x = Double(canvas.width/2 - offset)
            self.position.y *= -1
            base = true
        }
        if self.baseNode.position.y > canvas.height/2 {
            self.position.y = Double(-canvas.height/2 + offset)
            self.position.x *= -1
            base = true
        }
        if self.baseNode.position.y < -canvas.height/2 {
            self.position.y = Double(canvas.height/2 - offset)
            self.position.x *= -1
            base = true
        }
        if base {
            self.setPosition()
        }
    }
    
}
