import Foundation
import SpriteKit


/// Introduction of the game
public class GameIntro:GameScene {
    
    // Variable to tell how many levels have been unlocked already
    var unlockedLevels: Int = 0
    var selectedLevel: Int = 0
    
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        self.unlockedLevels = __GLOBAL_UNLOCKED_LEVELS
        let n = 50

        let z = ZoneBuilder(intervalX: (0)...(1), intervalY: (0)...(1), numOfAgents: n)
        arr.append(z)
        self.fireflies = arr
        
        // Call the super class initialization
        super.didMove(to: view)
    }
    
    public override func setupBehavior() {
        self.behaviors = [FlockBehavior(intensities: [0.05, 0.8, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 0, actionRadius: 5000), AvoidZone(intensity: 1)]
    }
    
    
    /// The level itself
    ///
    /// - Parameter canvas: The canvas size
    /// - Returns: The levels
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    
    /// The prizes in the level
    ///
    /// - Parameter canvas: The canvas size
    /// - Returns: The prizes list
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        var allPrizes:[Prize] = []
        
        if self.unlockedLevels == 0 {
            let prize1 = self.genPrize(px: 0.5, py: 0.6, canvas:canvas)
            self.genNumber(text: "1", prize: prize1)
            
            allPrizes.append(prize1)
        }
        else if self.unlockedLevels == 1 {
            let prize1 = self.genPrize(px: 0.3, py: 0.6, canvas:canvas)
            self.genNumber(text: "1", prize: prize1)
            
            let prize2 = self.genPrize(px: 0.7, py: 0.6, canvas:canvas)
            self.genNumber(text: "2", prize: prize2)
            
            allPrizes.append(prize1)
            allPrizes.append(prize2)
        }
        else if self.unlockedLevels == 2 {
            let prize1 = self.genPrize(px: 0.5, py: 0.8, canvas:canvas)
            self.genNumber(text: "1", prize: prize1)
            
            let prize2 = self.genPrize(px: 0.3, py: 0.5, canvas:canvas)
            self.genNumber(text: "2", prize: prize2)
            
            let prize3 = self.genPrize(px: 0.7, py: 0.5, canvas:canvas)
            self.genNumber(text: "3", prize: prize3)
            
            allPrizes.append(prize1)
            allPrizes.append(prize2)
            allPrizes.append(prize3)
        }
        else if self.unlockedLevels == 3 {
            let prize1 = self.genPrize(px: 0.5, py: 0.8, canvas:canvas)
            self.genNumber(text: "1", prize: prize1)
            
            let prize2 = self.genPrize(px: 0.2, py: 0.5, canvas:canvas)
            self.genNumber(text: "2", prize: prize2)
            
            let prize3 = self.genPrize(px: 0.5, py: 0.5, canvas:canvas)
            self.genNumber(text: "3", prize: prize3)
            
            let prize4 = self.genPrize(px: 0.8, py: 0.5, canvas:canvas)
            self.genNumber(text: "4", prize: prize4)
            
            allPrizes.append(prize1)
            allPrizes.append(prize2)
            allPrizes.append(prize3)
            allPrizes.append(prize4)
        }
        
        // Add the text label to indicate the game itself
        self.genText(text: "tap and hold", position: CGPoint(x: 0, y: canvas.minY + 0.1*canvas.height + 80))
        self.genText(text: "to guide fireflies to a level", position: CGPoint(x: 0, y: canvas.minY + 0.1*canvas.height))
        
        return allPrizes
    }
    
    
    /// Generate a prize in the screen
    ///
    /// - Parameters:
    ///   - px: The partial rate of the  screen for 0 to 1 in x
    ///   - py: The partial rate of the  screen for 0 to 1 in y
    ///   - canvas: The canvas size
    /// - Returns: The trophy
    func genPrize(px: CGFloat, py: CGFloat, canvas:CGRect) -> Prize {
        let prize:Prize = Prize(withTexture: "spark.png", size: 100, countToFill: 50)
        let x = canvas.width*px - canvas.width/2
        let y = canvas.height*py - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        prize.progressCircle.isAvaiable = false
        return prize
    }
    
    
    /// Generate a number over a sphere
    ///
    /// - Parameters:
    ///   - text: The text of the number
    ///   - prize: The object of the sphere
    func genNumber(text:String, prize:Prize) {
        let label = SKLabelNode(text: text)
        label.fontName = "GermaniaOne-Regular"
        label.position = CGPoint(x: prize.position.x, y: prize.position.y - 20)
        label.fontColor = .white
        label.fontSize = 60
        self.addChild(label)
    }
    
    
    /// Generate a text in the screen
    ///
    /// - Parameters:
    ///   - text: The text
    ///   - position: The position to generate
    func genText(text:String, position:CGPoint) {
        let label = SKLabelNode(text: text)
        label.fontName = "GermaniaOne-Regular"
        label.position = position
        label.fontColor = .lightGray
        label.fontSize = 60
        label.numberOfLines = 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .baseline
        label.preferredMaxLayoutWidth = (self.canvas?.width)!*0.8
        self.addChild(label)
    }
    
    
    /// Controls the agents update
    ///
    /// - Parameter currentTime: actual time since start of program
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime: TimeInterval = self.lastUpdateTime == 0 ? 0 : currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        // Checkup if all the prizes have been found
        for id in 0...(self.prizes.count - 1) {
            if prizes[id].didFinish() {
                self.selectedLevel = id
                self.finishLevel()
            }
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
    
    
    /// Does instantiate the next level
    override public func nextLevel() {
        if self.didStartFinish { return }
        self.didStartFinish = true
        
        let transition = SKTransition.fade(withDuration: 1)
        var partScene:GameScene? = nil
        
        __GLOBAL_POINTING_SPOT = nil
        
        if self.selectedLevel == 0 {
            partScene = Level0(fileNamed: "GameScene")
        }
        if self.selectedLevel == 1 {
            partScene = Level1(fileNamed: "GameScene")
        }
        if self.selectedLevel == 2 {
            partScene = Level2(fileNamed: "GameScene")
        }
        if self.selectedLevel == 3 {
            partScene = Level3(fileNamed: "GameScene")
        }
        
        
        if let scene = partScene {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene)
        }
    }
    
    
    /// Does make the necessary actions in the level finish
    override public func finishLevel() {
        let agents = self.agents
        self.agents = []
        self.pointingOutline.removeFromParent()
        self.playable = false
        
        self.playmusic(fileName: "level completion", withExtension: "mp3")
        
        let prize = self.prizes[self.selectedLevel]
        prize.agents = []
        prize.allowedUpdateAlpha = false
        
        let node = SKShapeNode(circleOfRadius: 1)
        node.fillColor = .yellow
        node.glowWidth = 10
        node.lineWidth = 0
        node.alpha = 0.05
        node.position = prize.position
        
        let act = SKAction.fadeOut(withDuration: 2)
        let act1 = SKAction.scale(by: (self.canvas?.width)!, duration: 2)
        self.addChild(node)
        
        for node in agents {
            node.run(act) {
                if node.parent != nil {
                    node.removeFromParent()
                }
            }
        }
        
        node.run(act1) {
            for c in self.children {
                c.run(act) {
                    c.removeFromParent()
                    self.nextLevel()
                }
            }
        }
    }
}
