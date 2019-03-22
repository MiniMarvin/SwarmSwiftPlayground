//
//  Prize.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 20/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//


import Foundation
import SpriteKit


public class Prize: SKSpriteNode {
    
    public var agents:[Boid] = []
    public var horizon:[Boid] = []
    public var innerCount:Int = 0
    public var countToFill:Int
    public var progressCount:Int = 0
    
    /// Size of prize's horizon
    public var fillHorizon:Int = 0
    public var progressCircle:CircularProgressBar
    public var allowedUpdateAlpha:Bool = true
    // MARK: Inits
    
    /// Creates a prize node
    ///
    /// - Parameters:
    ///   - file: The texture of the node
    ///   - size: The size of the sprite
    ///   - countToFill: Number of nodes necessary to make the sprite become felt
    public init(withTexture file:String = "spark.png", size:CGFloat, countToFill: Int) {
        
        let texture = SKTexture(imageNamed: file)
        self.countToFill = countToFill
        self.progressCircle = CircularProgressBar(radius: size * 0.8, width: 0.1 * size)
        self.progressCircle.zPosition = -1
        
        
        super.init(texture: texture, color: SKColor.clear, size: CGSize())
        
        self.alpha = 0.8
        self.color = .yellow
        self.colorBlendFactor = 0.1
        
        // Configure SpriteNode properties
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint.zero
        self.zPosition = 3
        self.name = "boid"
        self.size = CGSize(width: size, height: size)
        
        // Add glow
        let glow = SKSpriteNode(imageNamed: "spark.png")
        glow.size = CGSize(width: 3*size, height: 3*size)
        glow.blendMode = .alpha
        glow.alpha = 0.6
        glow.position = CGPoint.zero
        glow.color = .yellow
        glow.colorBlendFactor = 1
        glow.isHidden = false
        print(glow)
        self.addChild(glow)
        
        // Setup the fill horizon
        self.fillHorizon = Int(size)
        
        // Add progressbar
//        self.progressCircle.radius = self.size.width
        self.addChild(self.progressCircle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /// Computes which nodes are in the horizon
    ///
    /// - Parameter distance: The distance from the center that forms the horizon
    public func computeHorizon(distance: CGFloat) {
        var horizon:[Boid] = []
        var count = 0
        for agent in self.agents{
            let dist = self.position.distance(from: agent.position)
            if dist < distance {
                horizon.append(agent)
            }
            if Int(dist) <= self.fillHorizon {
                count += 1
            }
        }
        self.horizon = horizon
        self.progressCount = count
    }
    
    
    /// Set the sprite alpha
    public func setAlpha() {
        if self.allowedUpdateAlpha {
            self.alpha = 0.2 + 0.8*CGFloat(self.horizon.count)/CGFloat(self.countToFill)
        }
    }
    
    
    // TODO: Add sound
    // TODO: Add progress bar
    // TODO: Add red zone
    public func roundCircle() {
        self.progressCircle.value = 100*Double(self.progressCount)/Double(self.countToFill)
    }
    
    public func didFinish() -> Bool {
        return self.progressCount >= self.countToFill
    }
    
    // TODO: Add the drain zone of the fireflies
    
    // TODO: Add the keep feel zone
    
    
}
