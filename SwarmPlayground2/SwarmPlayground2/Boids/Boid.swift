//
//  Boid.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

// TODO: Update neighborhood with a lower rate
// TODO: Add a alpha blending logic to the scenario
// TODO: Enhance the behavio
// TODO: Avoid the v = -v behavior
// TODO: Add a method to make the flocks separe themselves

import Foundation
import SpriteKit

public enum BoidOrientation: Float {
    case north = 0
    case east = 270
    case south = 180
    case west = 90
}

public class Boid: SKSpriteNode {
    
    public var maximumFlockSpeed: Float = 2
    public var maximumGoalSpeed: Float = 4
    public var currentSpeed: Float = 2
    public var fearThreshold: Float = 100
    public var velocity = vector_float2([0,0])
    public var behaviors:[Behavior] = []
    public let momentum: Float = 6
    public let visionAngle: Float = 180
    
    public var id: Int = 0
    public var category: Int = 0
    
    public var sceneFrame = CGRect.zero
    public var neighborhood: [Boid] = []
    public var allNeighboors: [Boid] = []
    public var orientation: BoidOrientation = .west
    public var perceivedCenter = vector_float2([0,0])
    public var perceivedDirection = vector_float2([0,0])
    public var awayPerception = vector_float2([0,0])
    
    
    lazy var radius: Float = { return min(size.width.toDouble(), size.height.toDouble()) }()
    lazy var neighborhoodSize: Float = { return radius * 4 }()
    
    
//    public var emitter:SKEmitterNode = SKEmitterNode(fileNamed: "Blue.sks")!
    public var nearNodes:[Boid] = []
    
    public init(withTexture file:String = "play-arrow.png", category:Int = 0, id:Int = 0, size: CGFloat = 10, orientation: BoidOrientation = .west) {
        
        let texture = SKTexture(imageNamed: "firefly.png")
        super.init(texture: texture, color: SKColor.clear, size: CGSize())
        
        self.alpha = 0.4
        self.color = .yellow
        self.colorBlendFactor = 0.1
        
        // Add an emitter node
//        emitter.particleSize = CGSize(width:size/2, height:size)
//        emitter.position = CGPoint(x: 0, y: size/2)
//        self.addChild(emitter)
        
        // Configure SpriteNode properties
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 3
        self.name = "boid"
        self.id = id
        self.category = category
        self.size = CGSize(width: size, height: size)
        
        self.orientation = orientation
        // TODO: Behaviors
//        self.behaviors = [Cohesion(intensity: 0.02), Separation(intensity: 0.1), Alignment(intensity: 0.5), Bound(intensity:0.4)]
//        self.behaviors = [Cohesion(intensity: 0.1), Separation(intensity: 0.1), Alignment(intensity: 0.5), Bound(intensity:0.4)]
        self.behaviors = [FlockBehavior(intensities: [0.001, 0.8, 0.6]), Bound(intensity: 0.4), SeekFinger(intensity: 0.3)]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Updates
    
    public func updateBoid(inFlock flock: [Boid], deltaTime: TimeInterval) {
        // Apply each of the boid's behaviors
        
        for behavior in self.behaviors {
            if let cohension = behavior as? Cohesion {
                cohension.apply(toBoid: self, withCenterOfMass:perceivedCenter)
                continue
            }
            if let separation = behavior as? Separation {
                separation.apply(toBoid: self, inFlock: neighborhood)
                continue
            }
            if let alignment = behavior as? Alignment {
                alignment.apply(toBoid: self, withAlignment: perceivedDirection)
                continue
            }
            if let flockBehavior = behavior as? FlockBehavior {
                flockBehavior.apply(toBoid: self)
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
            if let seekFinger = behavior as? SeekFinger {
                seekFinger.apply(boid: self)
                continue
            }
            if let evade = behavior as? Evade {
                evade.apply(boid: self)
                continue
            }
        }
        
        self.alpha = 0.1 + 2*CGFloat(self.nearNodes.count)/CGFloat(self.allNeighboors.count)
//        self.emitter.alpha = self.alpha
        
        // Sum the velocities supplied by each of the behaviors
        var v = self.behaviors.reduce(self.velocity) { $0 + $1.scaledVelocity }
        // Add a noise to the vector by rotating it
        // Rotate randomly from -10 degrees to 10 degrees in the v vector
        let vl = v
        let t = Float.random(in: ClosedRange(uncheckedBounds: (-Float.pi/18, Float.pi/18)))
        v.x = vl.x*cos(t) - vl.y*sin(t)
        v.y = vl.x*sin(t) + vl.y*cos(t)
        
        self.velocity += v / self.momentum
        
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
        zRotation = CGFloat(-atan2(Float(velocity.x), Float(velocity.y))) - orientation.rawValue.toCGFloat().degreesToRadians
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
        
        var nearNodes:[Boid] = []
        var perceivedDirection = vector_float2([0,0])
        var perceivedCenter = vector_float2([0,0])
        var awayPerception = vector_float2([0,0])
        let total = Float(neighborhood.count)
        
        for node in neighborhood {
            perceivedDirection += node.velocity
            perceivedCenter += node.position.toVec()
            if node.position.distance(from: self.position) < 100 {
                nearNodes.append(node)
            }
            
            if node != self {
                let dist = node.position.distance(from: self.position).toDouble()
                if dist < self.radius*8 {
                    let awayVector = (node.position - self.position)
                    awayPerception -= awayVector.toVec()/dist
                }
            }
//            let awayVector = (node.position - self.position)
            
        }
        self.perceivedCenter = perceivedCenter/total
        self.perceivedDirection = perceivedDirection/total
        self.awayPerception = awayPerception
        self.nearNodes = nearNodes
        
//        for flockBoid in flock {
//            guard flockBoid != boid else { continue }
//
//            if boid.position.distance(from: flockBoid.position).toDouble() < boid.radius*2 {
//                let awayVector = (flockBoid.position - boid.position)
//                self.velocity -= awayVector.toVec() * (1/boid.position.distance(from: flockBoid.position).toDouble())
//            }
//        }
    }
    
    
    public func evaluateNeighborhood(forFlock flock: [Boid]) {
        self.neighborhood = flock.filter { boid in
            return isNeighboor(boid: boid)
        }
    }
    
}
