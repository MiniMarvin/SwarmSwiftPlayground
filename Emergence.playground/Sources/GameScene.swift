//
//  GameScene.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 17/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//
//  Reference: https://github.com/dionlarson/Duet-Trail-Effect-SpriteKit-Playground
// TODO: Add sound effects and music CRITICAL
// TODO: Remove the pointing effects after the finish level

import SpriteKit
import GameplayKit
import AVFoundation

public class GameScene: SKScene, Stage, Pointable {
    
    public final var agentsNum:Int {
        get {
            return self.fireflies.reduce(0, { (res, zn)in
                return res + zn.numOfAgents
            })
        }
    }
    
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
    public var wallBorder:CGFloat = 30

    public var playable: Bool = true
    public var musicPlayer:AVAudioPlayer?
    
    public var fireflies:[ZoneBuilder] = [ZoneBuilder(intervalX: (0)...(0.5), intervalY: (0.4)...(0.6), numOfAgents: 300)]
    public var behaviors:[Behavior] = []
    var pointingSize:CGFloat = 100
    
    public var pointingOutline:SKSpriteNode = SKSpriteNode(color: SKColor.red, size: CGSize(width: 0, height: 0))
    
    
    // Check every single prize
    public override func didMove(to view: SKView) {
        // Setup the scene
        self.backgroundColor = SKColor.black
        self.physicsWorld.speed = 0
        
        // Setup the canvas
        self.canvas = self.frame
        
        // Setup the maze
        self.scenario = self.levelZone(canvas: self.canvas!)
        
        // Setup the prizes
        self.prizes = self.levelPrizes(canvas: self.canvas!)
        
        // Setup the behavior
        self.setupBehavior()
        
        // Setup the agents
        self.buildAgents()
        
        // Setup the level agents into the prize itself
        for prize in prizes {
            prize.agents = self.agents
            prize.computeHorizon(distance: prizeHorizon)
            addChild(prize)
        }
        
        
        // Setup pointing
        setupPointing(size: self.pointingSize, pointingOutline: self.pointingOutline)
        
        
        // Setup the sprites of the maze
        self.buildDarkSprites()
        
        
        //Register for the applicationWillResignActive anywhere in your app.
//        let app = UIApplication.shared
//        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.applicationWillResignActive(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
    }
    
//    @objc func applicationWillResignActive(notification: NSNotification) {
//
//    }

    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Checkup if all the prizes have been found
        var prizeCounter = 0
        for prize in prizes {
            if prize.didFinish() {
                prizeCounter += 1
            }
        }
        
        if prizeCounter == prizes.count {
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
        if !self.playable { return }
        if let pt = touches.first?.location(in: self) {
            //            __GLOBAL_POINTING_SPOT = pt
            unlockGlobalPointing()
            setGlobalPointing(point: pt)
            
            addPointing(pointingOutline: self.pointingOutline, scene: self, point: pt)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.playable { return }
        if let pt = touches.first?.location(in: self) {
            //            __GLOBAL_POINTING_SPOT = pt
            setGlobalPointing(point: pt)
            
            updatePointing(pointingOutline: self.pointingOutline, point: pt)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.playable { return }
        //        __GLOBAL_POINTING_SPOT = nil
        unlockGlobalPointing()
        setGlobalPointing(point: nil)
        
        removePointing(pointingOutline: self.pointingOutline)
    }
    #endif
    
    
    
    // MARK: Audio Zone
    func playmusic(fileName name: String, withExtension ext:String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // The following line is required for the player to work on iOS 11. Change the file type accordingly
            self.musicPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = self.musicPlayer else { return }
            
            player.volume = 0.6
            player.play()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: Generator functions
    
    public func buildAgents() {
        var agents:[Boid] = []
        for zone in self.fireflies {
            let intervalX = zone.intervalX
            let intervalY = zone.intervalY
            let agentsNum = zone.numOfAgents
            
            // populate
            for i in 0...(agentsNum - 1) {
                let bd = Boid(withTexture: "firefly (2).png", category: 1, id: i, size: self.nodeSize, orientation: .north, behaviors: self.behaviors)
                
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
    
    public func setupBehavior() {
        self.behaviors = [FlockBehavior(intensities: [0.15, 0.4, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 40, actionRadius: 200), AvoidZone(intensity: 1), Seek(intensity: 0.2, prize: self.prizes[0])]
    }
    
    public func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0.4, widthFraction: 1, heightFraction: 0.2, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public func levelPrizes(canvas:CGRect) -> [Prize] {
        let prize:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: 300)
        let x = canvas.width*0.8 - canvas.width/2
        let y = canvas.height*0.5 - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        
        return [prize]
    }
    
    // MARK: Level finish
    
    public func finishLevel() {
        let agents = self.agents
        self.agents = []
        self.pointingOutline.removeFromParent()
        self.playable = false
        
        self.playmusic(fileName: "level completion", withExtension: "mp3")
        
        // TODO: Insert dark sprites here
        
        // Tune the trophy
        for prize in self.prizes {
            prize.agents = []
            prize.allowedUpdateAlpha = false
            
            
            
            let node = SKShapeNode(circleOfRadius: 1)
            node.fillColor = .yellow
            node.glowWidth = 10
            node.lineWidth = 0
            node.alpha = 0.05
            node.position = prize.position
            
            // Add a cropnode
//            let bgSprite = SKSpriteNode(imageNamed: "grass-gray-low.jpg")
//            bgSprite.alpha = 0
//            bgSprite.size = self.canvas!.size
//            bgSprite.position = CGPoint.zero
//            let crop = SKCropNode()
//            crop.position = CGPoint.zero
//            crop.addChild(bgSprite)
//            crop.maskNode = node
//            let fadeInAct = SKAction.fadeIn(withDuration: 7)
//            bgSprite.run(fadeInAct)
//            self.addChild(bgSprite)
            
            
            
            let act = SKAction.fadeOut(withDuration: 3)
            let act1 = SKAction.scale(by: 1.5*(self.canvas!).width, duration: 4)
            let group = SKAction.sequence([act1,act])
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
        if let scene = Level1(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene)
        }
    }
    
    
    
    /// Create all the dark squares
    public func buildDarkSprites() {
        let zones = self.scenario?.zones ?? []
        let wallborder = self.wallBorder
        for zone in zones {
            let sprites = zone.generateDarkSprites(wallborder: wallborder)
            for sprite in sprites {
                // Verify if the scene already have a node in the position
                let nodes = self.children
                var shouldAdd:Bool = true
                for node in nodes {
                    if sprite.position == node.position {
                        shouldAdd = false
                        break
                    }
                }
                if shouldAdd {
                    self.addChild(sprite)
                }
                
                // Get the edges* of the squares
                for sp in sprites {
                    if sp == sprite { continue }
                    var square = SKSpriteNode()
                    
                    // X zone
                    let b1 = sp.frame.contains(CGPoint(x: sprite.frame.maxX + 10, y: sprite.position.y + 10))
                    let b2 = sp.frame.contains(CGPoint(x: sprite.frame.maxX + 10, y: sprite.position.y - 10))
                    let b3 = sp.frame.contains(CGPoint(x: sprite.frame.minX - 10, y: sprite.position.y + 10))
                    let b4 = sp.frame.contains(CGPoint(x: sprite.frame.minX - 10, y: sprite.position.y - 10))
                    // Y zone
                    let b5 = sp.frame.contains(CGPoint(x: sprite.position.x + 10, y: sprite.frame.maxY + 10))
                    let b6 = sp.frame.contains(CGPoint(x: sprite.position.x - 10, y: sprite.frame.maxY + 10))
                    let b7 = sp.frame.contains(CGPoint(x: sprite.position.x + 10, y: sprite.frame.minY - 10))
                    let b8 = sp.frame.contains(CGPoint(x: sprite.position.x - 10, y: sprite.frame.minY - 10))
                    
                    // TODO: Remove the double adition
                    var shouldAdd = false
                    
                    if (b1 && !b2) || (!b1 && b2) {
                        square = SKSpriteNode(color: .black, size: CGSize(width: 2*wallborder, height: 2*wallborder))
                        square.position = CGPoint(x: sprite.frame.maxX, y: sprite.position.y)
                        shouldAdd = true
                    }
                    else if (b3 && !b4) || (!b3 && b4) {
                        square = SKSpriteNode(color: .black, size: CGSize(width: 2*wallborder, height: 2*wallborder))
                        square.position = CGPoint(x: sprite.frame.minX, y: sprite.position.y)
                        shouldAdd = true
                    }
                    else if (b5 && !b6) || (!b5 && b6) {
                        square = SKSpriteNode(color: .black, size: CGSize(width: 2*wallborder, height: 2*wallborder))
                        square.position = CGPoint(x: sprite.frame.maxY, y: sprite.position.x)
                        shouldAdd = true
                    }
                    else if (b7 && !b8) || (!b7 && b8) {
                        square = SKSpriteNode(color: .black, size: CGSize(width: 2*wallborder, height: 2*wallborder))
                        square.position = CGPoint(x: sprite.frame.minY, y: sprite.position.x)
                        shouldAdd = true
                    }
                    
                    let edgePoints = [10, -10]
                    
                    // Clean noise
                    // Search for 
                    var totalMix = false
                    for node in self.children {
                        if !shouldAdd { break }
                        
                        if square.position == node.position {
                            shouldAdd = false
                            break
                        }
                        
                        if node.name == "dark" {
                            for i in edgePoints {
                                for j in edgePoints {
                                    let pt = CGPoint(x: square.position.x + CGFloat(i), y: square.position.y + CGFloat(j))
                                    totalMix = totalMix || node.contains(pt)
                                }
                            }
                        }
                    }
                    shouldAdd = shouldAdd && totalMix
                    shouldAdd = shouldAdd && sprite.size.area() > 200
                    shouldAdd = shouldAdd && sp.size.area() > 200
                    
                    if shouldAdd {
                        square.name = "dark"
                        square.color = .black
                        square.zPosition = 30
                        addChild(square)
                        print("hehe")
                    }
                    
                }
            }
        }
    }
    
}
