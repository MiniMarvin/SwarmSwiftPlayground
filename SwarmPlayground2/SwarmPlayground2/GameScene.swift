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
    public let updateFrequency = 30
    public var nodeSize:CGFloat = 16
    public var scenario:Scenario?
    
    public override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        //        self.physicsWorld.speed = 0
        self.buildScenario()
        
        //        __GLOBAL_POINTING_SPOT = CGPoint(x: 300, y: -200)
        
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
                    boid.updateBoid(inFlock: self.agents, deltaTime: -startTime.timeIntervalSinceNow)
                }
            }
            else {
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
            //            let randomStartPositionX = CGFloat.random(in: 1...self.size.width) - self.size.width/2
            //            let randomStartPositionY = CGFloat.random(in: 1...self.size.height) - self.size.height/2
            let randomStartPositionX = CGFloat.random(in: 1...self.size.width/2) - self.size.width/2
            let randomStartPositionY = CGFloat.random(in: 1...self.size.height) - self.size.height/2
            bd.position = CGPoint(x: randomStartPositionX, y: randomStartPositionY)
            
            // Varying fear thresholds prevents "boid walls" during evade
            bd.fearThreshold = Float.random(in: bd.radius*4...bd.radius*6)
            
            // Assign slightly randomized speeds for variety in flock movement
            let randomFlockSpeed = Float.random(in: 2...3)
            let randomGoalSpeed = Float.random(in: 5...6)
            bd.maximumFlockSpeed = randomFlockSpeed
            bd.maximumGoalSpeed = randomGoalSpeed
            
            bd.scenario = self.scenario
            AvoidZone.updateZone(boid: bd)
            
            bd.name = "boid-\(i)"
            agents.append(bd)
        }
        
        // Setup the agents in the board
        agents.forEach { agent in
            agent.allNeighboors = agents
            agent.updatePerception()
            self.addChild(agent)
        }
        
        // Update the class variable
        self.agents = agents
    }
    
    public func buildScenario() {
        let pair = EdgePair(begin: 0.8, length: 1)
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 0.5, heightFraction: 1, canvas: self.frame, allowedEdgesFractions: [.right : [pair]])
        let zone2:Zone = Zone(startFractionX: 0.5, startFractionY: 0, widthFraction: 0.5, heightFraction: 1, canvas: self.frame, allowedEdgesFractions: [.left : [pair]])
        
        self.scenario = Scenario(zones: [zone1, zone2])
    }
    
    
    // TODO: Split by the version to mac and to iOS
    #if os(OSX)
    public override func mouseDown(with event: NSEvent) {
        let pt = event.location(in: self)
        //        __GLOBAL_POINTING_SPOT = pt
        unlockGlobalPointing()
        setGlobalPointing(point: pt)
    }
    
    public override func mouseDragged(with event: NSEvent) {
        let pt = event.location(in: self)
        //        __GLOBAL_POINTING_SPOT = pt
        setGlobalPointing(point: pt)
    }
    
    public override func mouseUp(with event: NSEvent) {
        //        __GLOBAL_POINTING_SPOT = nil
        unlockGlobalPointing()
        setGlobalPointing(point: nil)
    }
    
    #elseif os(iOS) || os(watchOS) || os(tvOS)
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let pt = touches.first?.location(in: self) {
            //            __GLOBAL_POINTING_SPOT = pt
            unlockGlobalPointing()
            setGlobalPointing(point: pt)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let pt = touches.first?.location(in: self) {
            //            __GLOBAL_POINTING_SPOT = pt
            setGlobalPointing(point: pt)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        __GLOBAL_POINTING_SPOT = nil
        unlockGlobalPointing()
        setGlobalPointing(point: nil)
    }
    #endif
    
    
    
    
}
