//
//  GameScene.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//
//  Reference: https://github.com/dionlarson/Duet-Trail-Effect-SpriteKit-Playground
// TODO: Add sound effects and music CRITICAL

import SpriteKit
import GameplayKit

public class GameScene: SKScene {
    
    public var agentsNum:Int = 300
    public var agents:[Boid] = []
    public var lastUpdateTime: TimeInterval = 0
    public var frameCount: Int = 0
    public let updateFrequency = 30
    public var nodeSize:CGFloat = 16
    public var scenario:Scenario?
    public var prize:Prize?
    public var prizeHorizon:CGFloat = 100
    public var canvas:CGRect?
    public var label:SKLabelNode?
    
    public override func didMove(to view: SKView) {
        // Setup the scene
        self.backgroundColor = SKColor.black
        self.physicsWorld.speed = 0
        
        // Setup the canvas
        //        self.canvas = self.view?.window?.frame
        self.canvas = self.frame
        //        print(self.view?.window)
        
        // Setup the maze
        self.scenario = Zone0(canvas: self.canvas!)
        
        // Setup the agents
        self.buildAgents(intervalX: (0)...(0.3), intervalY: (0.4)...(0.6))
        
        // Setup the prizes
        self.prize = prize0(canvas: self.canvas!)
        self.prize?.agents = self.agents
        self.prize?.computeHorizon(distance: prizeHorizon)
        self.addChild(prize!)
        
        // Debug label
        //        self.label = SKLabelNode(text: "apisdfjapdsiofjsdfpoij")
        //        self.label?.fontSize = 20
        //        self.label?.position = CGPoint.zero
        //        self.addChild(self.label!)
        
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Setup the alpha of the trophy
        if frameCount % 4 == 0 {
            DispatchQueue.global(qos: .background).async {
                self.prize?.computeHorizon(distance: self.prizeHorizon)
            }
            
            // Reload the position of everything
            //            if self.view?.window?.frame != self.canvas {
            //                if let newCanvas = self.view?.window?.frame{
            //                    if let oldCanvas = self.canvas {
            //
            //                        print(newCanvas, oldCanvas)
            ////                        self.canvas = self.view?.window?.frame
            //
            //                        // Reload the scene
            //                        self.reloadAgents(oldCanvas: oldCanvas, newCanvas: newCanvas)
            //                    }
            //                }
            //            }
        }
        else {
            DispatchQueue.global(qos: .background).async {
                self.prize?.setAlpha()
                //                print(self.prize?.alpha)
            }
        }
        
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
    
    // MARK: Generator functions
    
    public func buildAgents(intervalX:ClosedRange<CGFloat> = 0...(0.5), intervalY:ClosedRange<CGFloat> = 0...1) {
        var agents:[Boid] = []
        // populate
        for i in 0...(agentsNum - 1) {
            let bd = Boid(withTexture: "firefly (2).png", category: 1, id: i, size: self.nodeSize, orientation: .north)
            
            bd.id = i
            // Position the boid at a random scene location to start
            let randomStartPositionX = CGFloat.random(in: intervalX)*self.size.width - self.size.width/2
            let randomStartPositionY = CGFloat.random(in: intervalY)*self.size.height - self.size.height/2
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
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 0.5, heightFraction: 1, canvas: self.canvas!, allowedEdgesFractions: [.right : [pair]])
        let zone2:Zone = Zone(startFractionX: 0.5, startFractionY: 0, widthFraction: 0.5, heightFraction: 1, canvas: self.canvas!, allowedEdgesFractions: [.left : [pair]])
        
        self.scenario = Scenario(zones: [zone1, zone2])
    }
    
    // MARK: Reloaders DEPRECATED
    public func reloadAgents(oldCanvas:CGRect, newCanvas:CGRect) {
        for agent in self.agents {
            let px = agent.position.x/oldCanvas.size.width
            let py = agent.position.y/oldCanvas.size.height
            
            agent.position.x = px*newCanvas.size.width
            agent.position.y = py*newCanvas.size.height
        }
    }
    
    public func rebuildScenario(oldCanvas:CGRect, newCanvas:CGRect) {
        guard let zones = self.scenario?.zones else { return }
        for zone in zones {
            zone.canvas = newCanvas
            zone.buildScenarioRect()
        }
    }
    
    // MARK: Click controller
    
    
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
