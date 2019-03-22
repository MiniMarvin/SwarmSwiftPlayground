import Foundation
import SpriteKit

public class GameIntro:GameScene {
    
    // Variable to tell how many levels have been unlocked already
    var unlockedLevels: Int = 0
    var selectedLevel: Int = 0
    
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        let frac = 20
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
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        var allPrizes:[Prize] = []
        
        let prize = self.genPrize(px: 0.2, py: 0.7, canvas:canvas)
        allPrizes.append(prize)
        self.genNumber(text: "1", prize: prize)
        
        if self.unlockedLevels > 0 {
            let prize = self.genPrize(px: 0.5, py: 0.7, canvas:canvas)
            allPrizes.append(prize)
            // Add the label
            self.genNumber(text: "2", prize: prize)
        }
        if self.unlockedLevels > 1 {
            let prize = self.genPrize(px: 0.8, py: 0.7, canvas:canvas)
            allPrizes.append(prize)
            // Add the label
            self.genNumber(text: "3", prize: prize)
        }
        if self.unlockedLevels > 2 {
            let prize = self.genPrize(px: 0.2, py: 0.3, canvas:canvas)
            allPrizes.append(prize)
            // Add the label
            self.genNumber(text: "4", prize: prize)
        }
        if self.unlockedLevels > 3 {
            let prize = self.genPrize(px: 0.5, py: 0.3, canvas:canvas)
            allPrizes.append(prize)
            // Add the label
            self.genNumber(text: "5", prize: prize)
        }
        if self.unlockedLevels > 4 {
            let prize = self.genPrize(px: 0.8, py: 0.3,canvas:canvas)
            allPrizes.append(prize)
            // Add the label
            self.genNumber(text: "6", prize: prize)
        }
        
        return allPrizes
    }
    
    func genPrize(px: CGFloat, py: CGFloat, canvas:CGRect) -> Prize {
        let prize:Prize = Prize(withTexture: "spark.png", size: 100, countToFill: 35)
        let x = canvas.width*px - canvas.width/2
        let y = canvas.height*py - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        
        return prize
    }
    
    func genNumber(text:String, prize:Prize) {
        let label = SKLabelNode(text: text)
        label.position = CGPoint(x: prize.position.x - 5, y: prize.position.y - 20)
        label.color = .yellow
        label.fontSize = 60
        self.addChild(label)
    }
    
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
    
    
    override public func nextLevel() {
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
        
        
        if let scene = partScene {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene)
        }
    }
}
