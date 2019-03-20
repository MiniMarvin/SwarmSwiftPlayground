//  Reference: https://github.com/christopherkriens/boids
//
//  Behavior.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//
//  Obs: These methods have been rewritten in part to conform to
//  the needs to make a posterior update to Metal.


import Foundation
import SpriteKit

public protocol Behavior: AnyObject {
    // The result velocity after the calculation
    var velocity: vector_float2 { get }
    
    // The intensity applied to the velocity, bounded 0.0 to 1.0
    var intensity: Float { get set }
    
    var name: String { get }
    
    //    var name: String { get set }
    
    init(intensity: Float)
    
    init()
}



/**
 This extension provides a default implementation for initialization, so
 that each class that adopts the protocol doesn't need to duplicate this
 common functionality, as well as a computed property for accessing the
 scaled vector.
 */
public extension Behavior {
    public init(intensity: Float) {
        self.init()
        self.intensity = intensity
        
        // Make sure that intensity gets capped between 0 and 1
        let valid: ClosedRange<Float> = 0.0...1.0
        guard valid.contains(intensity) else {
            self.intensity = (round(intensity) > valid.upperBound/2) ? valid.lowerBound : valid.upperBound
            return
        }
    }
    
    public var scaledVelocity: vector_float2 {
        return velocity*intensity
    }
}

/**
 This behavior applies a tendency to move the boid toward a position.
 This position tends to be the averaged position of the entire flock
 or a smaller group.
 */
public class Cohesion: Behavior {
    public var name: String = "cohesion"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    
    public required init() { }
    
    public func apply(toBoid boid: Boid, withCenterOfMass centerOfMass: vector_float2) {
        self.velocity = (centerOfMass - boid.position.toVec())
    }
    
    public func apply(toBoid boid: Boid, withNeighboors neighborhood:[Boid]) {
        let perceivedCenter = (neighborhood.reduce(vector_float2([0,0])) { $0 + $1.position.toVec() }) / Float(neighborhood.count)
        self.apply(toBoid: boid, withCenterOfMass: perceivedCenter)
    }
    
    public func apply(toBoid boid: Boid) {
        if boid.getNeighboors().count == 0 {
            self.velocity = vector_float2([0,0])
        }
        else {
            self.apply(toBoid: boid, withNeighboors: boid.getNeighboors())
        }
    }
}

/**
 This behavior applies a tendency to move away from neighbors when
 they get too close together.  Prevents the proclivity to stack up
 on one another.
 */
public class Separation: Behavior {
    public var name: String = "separation"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    
    public required init() { }
    
    func apply(toBoid boid: Boid, inFlock flock: [Boid]) {
        self.velocity = vector_float2([0,0])
        
        for flockBoid in flock {
            guard flockBoid != boid else { continue }
            
            if boid.position.distance(from: flockBoid.position).toDouble() < boid.radius*2 {
                let awayVector = (flockBoid.position - boid.position)
                self.velocity -= awayVector.toVec() * (1/boid.position.distance(from: flockBoid.position).toDouble())
            }
        }
    }
    
    func apply(toBoid boid: Boid) {
        self.apply(toBoid: boid, inFlock: boid.getNeighboors())
    }
}


/**
 This behavior applies a tendency for a boid to align its
 direction with the average direction of the entire flock.
 */
public class Alignment: Behavior {
    public var name: String = "alignment"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    
    public required init() { }
    
    func apply(toBoid boid: Boid, withAlignment alignment: vector_float2) {
        self.velocity = (alignment - boid.velocity)
    }
    
    func apply(toBoid boid:Boid, withNeighboors neighborhood: [Boid]) {
        let perceivedDirection = (neighborhood.reduce(vector_float2([0,0])) { $0 + $1.velocity }) / Float(neighborhood.count)
        self.apply(toBoid: boid, withAlignment: perceivedDirection)
    }
    
    func apply(toBoid boid:Boid) {
        if boid.getNeighboors().count == 0 {
            self.velocity = vector_float2([0,0])
        }
        else {
            self.apply(toBoid: boid, withNeighboors: boid.getNeighboors())
        }
    }
}


/**
 This behavior applies a tendency for a boid to move away
 from the edges of the screen within a configurable margin.
 */
public class Bound: Behavior {
    public var name: String = "bound"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    
    public required init() { }
    
    func apply(toBoid boid: Boid) {
        self.velocity = vector_float2([0,0])
        
        // Make sure each boid has a parent scene frame
        guard let frame = boid.parent?.frame else {
            return
        }
        
        let borderMargin: Float = 10
        let borderAversion: Float = boid.currentSpeed
        
        let horizontal = (-frame.size.width.toDouble()/2 + borderMargin)...(frame.size.width.toDouble()/2 - borderMargin)
        let vertical = (-frame.size.height.toDouble()/2 + borderMargin)...(frame.size.height.toDouble()/2 - borderMargin)
        
        if boid.position.x.toDouble() < horizontal.lowerBound {
            self.velocity.x += borderAversion
        }
        
        if boid.position.x.toDouble() > horizontal.upperBound {
            self.velocity.x -= borderAversion
        }
        
        if boid.position.y.toDouble() < vertical.lowerBound {
            self.velocity.y += borderAversion
        }
        
        if boid.position.y.toDouble() > vertical.upperBound {
            self.velocity.y -= borderAversion
        }
    }
}


/**
 This behavior applies a tendency for a boid to move toward a
 particular point.  Seek is a temporary behavior that removes
 itself from the boid once the goal is reached.
 */
public class Seek: Behavior {
    public var name: String = "seek"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    public var point: vector_float2 = vector_float2([0,0])
    
    public required init() { }
    
    
    convenience init(intensity: Float, point: vector_float2) {
        self.init(intensity: intensity)
        self.point = point
    }
    
    func apply(boid: Boid) {
        // Approximate touch size
        let goalThreshhold: CGFloat = 44.0
        
        // Remove this behavior once the goal has been reached
        guard boid.position.outside(goalThreshhold, of: point.toCGPoint()) else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.behaviors = boid.behaviors.filter { $0 as? Seek !== self }
            return
        }
        boid.currentSpeed = boid.maximumGoalSpeed
        velocity = (self.point - boid.position.toVec())
    }
}


/**
 This behavior applies a tendency for a boid to move away from
 a particular point.  Evade is a temporary behavior that
 removes itself from the boid once outside of `fearThreshold`.
 */
public class Evade: Behavior {
    public var name: String = "evade"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    public var point: vector_float2 = vector_float2([0,0])
    
    public required init() { }
    
    public convenience init(intensity: Float, point: vector_float2) {
        self.init(intensity: intensity)
        self.point = point
    }
    
    public func apply(boid: Boid) {
        // Remove this behavior once the goal has been reached
        guard boid.position.within(boid.fearThreshold.toCGFloat(), of: point.toCGPoint()) else {
            boid.currentSpeed = boid.maximumFlockSpeed
            boid.behaviors = boid.behaviors.filter { $0 as? Evade !== self }
            return
        }
        self.velocity = boid.position.toVec() - self.point
        
        let multiplier: Float = 150
        let distanceFromTouch = boid.position.distance(from: point.toCGPoint()).toDouble()
        let evadeSpeed = boid.maximumGoalSpeed * (multiplier/distanceFromTouch)
        boid.currentSpeed = evadeSpeed < boid.maximumFlockSpeed ? boid.maximumFlockSpeed : evadeSpeed
    }
}

public class FlockBehavior: Behavior {
    public var name: String = "flockbehavior"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 1.0
    public var intensities: [Float] = []
    public var scaledVelocity: vector_float2 {
        return velocity
    }
    
    public required init() { }
    
    public convenience init(intensities: [Float]) {
        self.init(intensity: 1)
        self.intensities = intensities
    }
    
    public func apply(toBoid boid: Boid) {
        
        let alignment = boid.perceivedDirection - boid.velocity
        let cohesion = boid.perceivedCenter - boid.position.toVec()
        let separation = boid.awayPerception
        //        let noise = vector_float2(x: Float.random(in: ClosedRange(uncheckedBounds: (-0.3, 0.3))), y: Float.random(in: ClosedRange(uncheckedBounds: (-0.3, 0.3))))
        
        self.velocity = cohesion*self.intensities[0] + separation*self.intensities[1] + alignment*intensities[2]
    }
}

/// WARNING: for performance reasons this behavior uses a GLOBAL VARIABLE!!!
public class SeekFinger: Behavior {
    public var name: String = "seekfinger"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    public var centerRadius: CGFloat = 20.0
    public var actionRadius: CGFloat = 200.0
    
    public required init() { }
    
    public convenience init(intensity: Float, centerRadius:CGFloat, actionRadius:CGFloat) {
        self.init(intensity:intensity)
        self.centerRadius = centerRadius
        self.actionRadius = actionRadius
    }
    
    func apply(boid: Boid) {
        // Approximate touch size
        //        let goalThreshhold: CGFloat = 60.0
        self.velocity = vector_float2([0,0])
        
        guard let pt = __GLOBAL_POINTING_SPOT else { return }
        
        // Remove this behavior once the goal has been reached
        guard boid.position.outside(self.centerRadius, of: pt) else {
            return
        }
        
        if boid.position.outside(self.actionRadius, of: pt) {
            return
        }
        
        //        boid.currentSpeed = boid.maximumGoalSpeed
        self.velocity = (pt - boid.position).toVec()
    }
}


public class AvoidZone: Behavior {
    public var name: String = "avoidzone"
    public var velocity: vector_float2 = vector_float2([0,0])
    public var intensity: Float = 0.0
    
    public required init() { }
    
    func apply(toBoid boid: Boid, borderMargin: Float) {
        self.velocity = vector_float2([0,0])
        
        // Make sure each boid has a parent scene frame
        guard let _ = boid.parent?.frame else {
            return
        }
//        print("aaaaa")
        
        // Make sure that the scenario does exist
        guard let _ = boid.scenario else {
            return
        }
//        print("bbbbb")
        
        guard let zone = boid.zone else {
            return
        }
//        print("ccccc")
        
        let borderAversion:Float = 1000
        
        let h0 = zone.computedRect.minY
        let h1 = zone.computedRect.maxY
        let w0 = zone.computedRect.minX
        let w1 = zone.computedRect.maxX
        
        
//        print(h0, h1, w0, w1)
        
        if boid.position.x < w0 {
            var allowed = false
            // verify if it is in the allowed border
            if let edges = zone.allowedEdges[.left] {
                for edge in edges {
                    if edge.contains(position: boid.position.y) {
                        allowed = true
                        break
                    }
                }
            }
            
            if !allowed {
                self.velocity.x += borderAversion
//                print("left")
            }
            else { AvoidZone.updateZone(boid: boid) }
        }
        
        if boid.position.x > w1 {
            // Verify if it is in the allowed border
            var allowed = false
            // verify if it is in the allowed border
            if let edges = zone.allowedEdges[.right] {
                for edge in edges {
                    //                    print(edge, boid.position.y)
                    if edge.contains(position: boid.position.y) {
                        allowed = true
                        break
                    }
                }
            }
            
            if !allowed {
                self.velocity.x -= borderAversion
//                print("right")
            }
            else { AvoidZone.updateZone(boid: boid) }
        }
        
        if boid.position.y < h0 {
            // Verify if it is in the allowed border
            var allowed = false
            // verify if it is in the allowed border
            if let edges = zone.allowedEdges[.bottom] {
                for edge in edges {
                    if edge.contains(position: boid.position.x) {
                        allowed = true
                        break
                    }
                }
            }
            
            if !allowed {
                self.velocity.y += borderAversion
//                print("top")
            }
            else { AvoidZone.updateZone(boid: boid) }
        }
        
        if boid.position.y > h1 {
            // Verify if it is in the allowed border
            var allowed = false
            // verify if it is in the allowed border
            if let edges = zone.allowedEdges[.top] {
                for edge in edges {
                    if edge.contains(position: boid.position.x) {
                        allowed = true
                        break
                    }
                }
            }
            
            if !allowed { self.velocity.y -= borderAversion }
            else {
                AvoidZone.updateZone(boid: boid)
//                print("bottom")
            }
        }
    }
    
    public static func updateZone(boid:Boid) {
        guard let zones = boid.scenario?.zones else { return }
//        print("iiiiihaaaa")
        for zone in zones {
            //            print(zone.computedRect, boid.position, zone.computedRect.contains(boid.position))
//            print(zone.computedRect, boid.position)
            if zone.computedRect.contains(boid.position) {
                boid.zone = zone
                break
            }
        }
    }
}
