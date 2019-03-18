//
//  GameScene.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//
//  Reference: https://github.com/dionlarson/Duet-Trail-Effect-SpriteKit-Playground

import SpriteKit
import GameplayKit

public class GameScene: SKScene {
    
    public var agentsNum:Int = 600
    public var agents:[Boid] = []
    public var lastUpdateTime: TimeInterval = 0
    public var frameCount: Int = 0
    public let updateFrequency = 60
    public var nodeSize:CGFloat = 8
    
    public override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        
        self.buildAgents()
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        for boid in self.agents {
            // Each boid should reevaluate its neighborhood and perception every so often
            if frameCount % updateFrequency == 0 {
                
                DispatchQueue.global(qos: .background).async {
                    let startTime = Date()
                    boid.evaluateNeighborhood(forFlock: self.agents)
                    boid.updatePerception()

//                    DispatchQueue.main.async {
                    boid.updateBoid(inFlock: self.agents, deltaTime: -startTime.timeIntervalSinceNow)
//                    }
                }
            } else {
                boid.updateBoid(inFlock: self.agents, deltaTime: deltaTime)
            }
        }
        
        frameCount += 1
    }
    
    public func buildAgents() {
        var agents:[Boid] = []
        // populate
        for i in 0...(agentsNum - 1) {
            let bd = Boid(withTexture: "play-arrow.png", category: 1, id: i, size: self.nodeSize, orientation: .north)
            bd.id = i
            // Position the boid at a random scene location to start
            let randomStartPositionX = CGFloat.random(in: 1...self.size.width) - self.size.width/2
            let randomStartPositionY = CGFloat.random(in: 1...self.size.height) - self.size.height/2
            bd.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            
            // Varying fear thresholds prevents "boid walls" during evade
            bd.fearThreshold = Float.random(in: bd.radius*4...bd.radius*6)
            
            // Assign slightly randomized speeds for variety in flock movement
            let randomFlockSpeed = Float.random(in: 2...3)
            let randomGoalSpeed = Float.random(in: 5...6)
            bd.maximumFlockSpeed = randomFlockSpeed
            bd.maximumGoalSpeed = randomGoalSpeed
            
            bd.name = "boid-\(i)"
            agents.append(bd)
        }
        
        // Setup the agents in the board
        agents.forEach { agent in
            agent.allNeighboors = agents
            self.addChild(agent)
        }
        
        // Update the class variable
        self.agents = agents
    }
}
