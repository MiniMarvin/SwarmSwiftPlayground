//
//  Boid.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

// TODO: Update neighborhood with a lower rate

import Foundation
import SpriteKit

public enum BoidOrientation: Double {
    case north = 0
    case east = 270
    case south = 180
    case west = 90
}

public class Boid: SKSpriteNode {
    
    public var maximumFlockSpeed: Double = 2
    public var maximumGoalSpeed: Double = 4
    public var currentSpeed: Double = 2
    public var fearThreshold: Double = 100
    public var velocity = vector_double2([0,0])
    public var behaviors:[Behavior] = []
    public let momentum: Double = 6
    public let visionAngle: Double = 180
    
    public var id: Int = 0
    public var category: Int = 0
    
    public var sceneFrame = CGRect.zero
    public var neighborhood: [Boid] = []
    public var allNeighboors: [Boid] = []
    public var orientation: BoidOrientation = .west
    public var perceivedCenter = vector_double2([0,0])
    public var perceivedDirection = vector_double2([0,0])
    
    
    lazy var radius: Double = { return min(size.width.toDouble(), size.height.toDouble()) }()
    lazy var neighborhoodSize: Double = { return radius * 4 }()
    
    
    public init(withTexture file:String = "play-arrow.png", category:Int = 0, id:Int = 0, size: CGFloat = 10, orientation: BoidOrientation = .west) {
        
        let texture = SKTexture(imageNamed: file)
        super.init(texture: texture, color: SKColor.clear, size: CGSize())
        
        // Configure SpriteNode properties
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 2
        self.name = "boid"
        self.id = id
        self.category = category
        self.size = CGSize(width: size, height: size)
        
        self.orientation = orientation
        // TODO: Behaviors
        self.behaviors = [Cohesion(intensity: 0.02), Separation(intensity: 0.1), Alignment(intensity: 0.3), Bound(intensity:0.4)]
//        self.behaviors = []
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Updates
    
    public func updateBoid(inFlock flock: [Boid], deltaTime: TimeInterval) {
        // Apply each of the boid's behaviors
        
        for behavior in self.behaviors {
            if let cohension = behavior as? Cohesion {
//                cohension.apply(toBoid: self)
                cohension.apply(toBoid: self, withCenterOfMass:perceivedCenter)
                continue
            }
            if let separation = behavior as? Separation {
//                separation.apply(toBoid: self)
                separation.apply(toBoid: self, inFlock: neighborhood)
                continue
            }
            if let alignment = behavior as? Alignment {
//                alignment.apply(toBoid: self)
                alignment.apply(toBoid: self, withAlignment: perceivedDirection)
                continue
            }
            if let bound = behavior as? Bound {
                bound.apply(toBoid: self)
                continue
            }
            if let seek = behavior as? Seek {
                seek.apply(boid: self)
                continue
            }
            if let evade = behavior as? Evade {
                evade.apply(boid: self)
                continue
            }
        }
        
        // Sum the velocities supplied by each of the behaviors
        let v = self.behaviors.reduce(self.velocity) { $0 + $1.scaledVelocity }
//        print("v: ", v)
//        print("center: ", self.perceivedCenter)
//        print("direction:", self.perceivedDirection)
//        if v.x.isNaN || self.perceivedCenter.x.isNaN || self.perceivedDirection.x.isNaN {
//            print("here8")
//        }
        self.velocity += v / momentum
        
        // Limit the maximum velocity per update
        self.applySpeedLimit()
        
        // Stay rotated toward the direction of travel
        self.rotate()
        
        // Update the position on screen
        // TODO: Modify this update to the physics body version
        self.position += self.velocity.toCGPoint() * (CGFloat(deltaTime) * 60)
    }
    
    
}


// Movement control
public extension Boid {
    /// Limit the speed of the boid
    public func applySpeedLimit() {
        let vector = simd_length(self.velocity)
        if vector > self.currentSpeed {
            let unit = self.velocity/vector
            self.velocity = unit*self.currentSpeed
        }
    }
    
    public func rotate() {
        zRotation = CGFloat(-atan2(Double(velocity.x), Double(velocity.y))) - orientation.rawValue.toCGFloat().degreesToRadians
    }
}


// Neightboors
public extension Boid {
    public func getNeighboors() -> [Boid] {
        return self.allNeighboors.filter { boid in
            return isNeighboor(boid: boid)
        }
    }
    
    public func isNeighboor(boid:Boid) -> Bool {
        if boid.position.distance(from: self.position).toDouble() < self.neighborhoodSize {
            // Computes if the node is in the vision angle
            if self.isVisible(boid: boid) { return true }
        }
        return false
    }
    
    public func isVisible(boid: Boid) -> Bool {
        // Remove itself from neighborhood
        if boid == self {
            return false
        }
        
        let lowerBound = boid.velocity.toCGPoint().pointByRotatingAround(boid.position, byDegrees: CGFloat(-visionAngle/2))
        let upperBound = boid.velocity.toCGPoint().pointByRotatingAround(boid.position, byDegrees: CGFloat(visionAngle/2))
        
        if (lowerBound * boid.velocity.toCGPoint()) * (lowerBound * upperBound) >= 0 && (upperBound * boid.velocity.toCGPoint()) * (upperBound * lowerBound) >= 0 {
            return true
        }
        
        return false
    }
    
    
    public func updatePerception() {
        if neighborhood.count == 0 {
            return
        }
        self.perceivedDirection = (neighborhood.reduce(vector_double2([0,0])) { $0 + $1.velocity }) / Double(neighborhood.count)
        self.perceivedCenter = (neighborhood.reduce(vector_double2([0,0])) { $0 + $1.position.toVec() }) / Double(neighborhood.count)
    }
    
    public func evaluateNeighborhood(forFlock flock: [Boid]) {
        self.neighborhood = flock.filter { boid in
            return isNeighboor(boid: boid)
        }
    }
    
}
