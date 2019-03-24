import Foundation
import SpriteKit

public class GameName:GameScene {
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        let n = 800
        
        let z1 = ZoneBuilder(intervalX: 0.4...0.6, intervalY: 0.4...0.6, numOfAgents: 400)
        let z2 = ZoneBuilder(intervalX: 0.6...0.7, intervalY: 0.45...0.55, numOfAgents: 100)
        let z3 = ZoneBuilder(intervalX: 0.3...0.4, intervalY: 0.45...0.55, numOfAgents: 100)
        let z4 = ZoneBuilder(intervalX: 0.45...0.55, intervalY: 0.6...0.7, numOfAgents: 100)
        let z5 = ZoneBuilder(intervalX: 0.45...0.55, intervalY: 0.3...0.4, numOfAgents: 100)
        
        self.fireflies = [z1, z2, z3, z4, z5]
        
        // Call the super class initialization
        super.didMove(to: view)
    }
    
    public override func setupBehavior() {
        self.behaviors = [FlockBehavior(intensities: [0.5, 0.5, 0.5]), SeekFinger(intensity: 0.8, centerRadius: 0, actionRadius: 30), AvoidZone(intensity: 1)]
    }
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        let allPrizes:[Prize] = []
        return allPrizes
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
    
}





