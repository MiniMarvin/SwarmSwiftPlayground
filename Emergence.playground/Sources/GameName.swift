import Foundation
import SpriteKit

public class GameName:GameScene {
    
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
    
    
    override public func buildAgents() {
        var agents:[Boid] = []
        for zone in self.fireflies {
            let intervalX = zone.intervalX
            let intervalY = zone.intervalY
            let agentsNum = zone.numOfAgents
            
            // populate
            for i in 0...(agentsNum - 1) {
                
                let y = i - agentsNum/2
                var x = 100
                if i > agentsNum/2 {x = -100}
                let bd = Boid(withTexture: "firefly (2).png", category: 1, id: i, size: self.nodeSize, orientation: .north,
                              behaviors: [FlockBehavior(intensities: [0.05, 0.8, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 1, centerRadius: 0, actionRadius: 5000), AvoidZone(intensity: 1), SeekPoint(intensity: 1, point: CGPoint(x: x, y: y), actionRadius: 1000, multiplier: 2)])
                
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
    
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        let allPrizes:[Prize] = []
        return allPrizes
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
