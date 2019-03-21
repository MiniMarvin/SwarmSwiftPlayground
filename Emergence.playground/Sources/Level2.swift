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

public class Level2: SKScene, Stage {
    
    public var agentsNum:Int = 400
    public var agents:[Boid] = []
    public var lastUpdateTime: TimeInterval = 0
    public var frameCount: Int = 0
    public let updateFrequency = 30
    public var nodeSize:CGFloat = 16
    public var scenario:Scenario?
    public var prizes:[Prize] = []
    public var prizeHorizon:CGFloat = 100
    public var canvas:CGRect?
    public var label:SKLabelNode?
//    public var circle:CircularProgressBar?
    public var pointingOutline:SKSpriteNode = SKSpriteNode(imageNamed: "circle-outline.png")
    
    // Check every single prize
    
    public override func didMove(to view: SKView) {
        // Setup the scene
        self.backgroundColor = SKColor.black
//        self.physicsWorld.speed = 0
        
        // Setup the canvas
//        self.canvas = self.view?.window?.frame
        self.canvas = self.frame
//        print(self.view?.window)
        
        // Setup the maze
        self.scenario = self.levelZone(canvas: self.canvas!)
        
        // Setup the agents
        self.buildAgents(intervalX: (0)...(0.4), intervalY: (0.6)...(1))
        
        // Setup the prizes
        self.prizes = self.levelPrizes(canvas: self.canvas!)
        for prize in prizes {
            prize.agents = self.agents
            prize.computeHorizon(distance: prizeHorizon)
            addChild(prize)
        }
        
        
        // Setup pointing
        setupPointing(size: 100, pointingOutline: self.pointingOutline)
        
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Checkup if all the prizes have been found
        var prizeCounter = 0
        for prize in prizes {
//            print(prize.didFinish())
            if prize.didFinish() {
                prizeCounter += 1
            }
        }
        
        if prizeCounter == prizes.count {
//            print("ihhuhuhuhu")
            self.finishLevel()
        }
        
        // Setup the alpha of the trophy
        if frameCount % 4 == 0 {
            DispatchQueue.global(qos: .background).async {
                for prize in self.prizes {
                    prize.computeHorizon(distance: self.prizeHorizon)
                }
            }
        }
        else {
        DispatchQueue.global(qos: .background).async {
                for prize in self.prizes {
                    prize.setAlpha()
                }
            }
            // WARNING: Must be sync to avoid memory access error!!!!
            for prize in self.prizes {
                prize.roundCircle()
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
            
            addPointing(pointingOutline: self.pointingOutline, scene: self, point: pt)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let pt = touches.first?.location(in: self) {
            //            __GLOBAL_POINTING_SPOT = pt
            setGlobalPointing(point: pt)
            
            updatePointing(pointingOutline: self.pointingOutline, point: pt)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        __GLOBAL_POINTING_SPOT = nil
        unlockGlobalPointing()
        setGlobalPointing(point: nil)
        
        removePointing(pointingOutline: self.pointingOutline)
    }
    #endif
    
    // MARK: Finish level
    public func finishLevel() {
        let agents = self.agents
        self.agents = []
        
        // Tune the trophy
        for prize in self.prizes {
            prize.agents = []
            prize.allowedUpdateAlpha = false
            let node = SKShapeNode(circleOfRadius: 1)
            node.fillColor = .yellow
//            node.strokeColor = .yellow
            node.glowWidth = 10
            node.lineWidth = 0
            node.alpha = 0.05
            node.position = prize.position
            let act = SKAction.fadeOut(withDuration: 2)
            let act1 = SKAction.scale(by: (self.canvas?.width)!, duration: 2)
            let group = SKAction.group([act, act1])
            self.addChild(node)
            node.run(group) {
                node.removeFromParent()
            }
            prize.run(act) {
                prize.removeFromParent()
                self.nextLevel()
            }
        }
        
        // Tune the agent
        for agent in agents {
            // TODO: Add smooth remotion
            agent.removeAllChildren()
            agent.removeFromParent()
        }
    }
    
    public func nextLevel() {
        let transition = SKTransition.fade(withDuration: 1)
        let nlvl = GameScene(fileNamed: "GameScene")
        self.view?.presentScene(nlvl)
    }
    
    
    // Level Buildups
    public func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0.5, widthFraction: 0.5, heightFraction: 0.5, canvas: canvas, allowedEdgesFractions: [.right:[EdgePair(begin: 0, length: 0.5)]])
        let zone2:Zone = Zone(startFractionX: 0.5, startFractionY: 0.5, widthFraction: 0.5, heightFraction: 0.5, canvas: canvas, allowedEdgesFractions: [.left:[EdgePair(begin: 0, length: 0.5)], .bottom: [EdgePair(begin: 0.5, length: 0.5)]])
        let zone3:Zone = Zone(startFractionX: 0.5, startFractionY: 0, widthFraction: 0.5, heightFraction: 0.5, canvas: canvas, allowedEdgesFractions: [.left:[EdgePair(begin: 0, length: 0.5)], .top: [EdgePair(begin: 0.5, length: 0.5)]])
        let zone4:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 0.5, heightFraction: 0.5, canvas: canvas, allowedEdgesFractions: [.right:[EdgePair(begin: 0, length: 0.5)]])
        
        return Scenario(zones: [zone1, zone2, zone3, zone4])
    }
    
    public func levelPrizes(canvas:CGRect) -> [Prize] {
        let prize:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: 400)
        let x = canvas.width*0.2 - canvas.width/2
        let y = canvas.height*0.3 - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        
        return [prize]
    }
    
}
