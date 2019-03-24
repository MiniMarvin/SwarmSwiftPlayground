import Foundation
import SpriteKit


public class Level3 : GameScene {
    
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        
        let z1 = ZoneBuilder(intervalX: 0.4...0.6, intervalY: 0.4...0.6, numOfAgents: 200)
        let z2 = ZoneBuilder(intervalX: 0.6...0.7, intervalY: 0.45...0.55, numOfAgents: 75)
        let z3 = ZoneBuilder(intervalX: 0.3...0.4, intervalY: 0.45...0.55, numOfAgents: 75)
        let z4 = ZoneBuilder(intervalX: 0.45...0.55, intervalY: 0.6...0.7, numOfAgents: 75)
        let z5 = ZoneBuilder(intervalX: 0.45...0.55, intervalY: 0.3...0.4, numOfAgents: 75)
                
        self.fireflies = [z1, z2, z3, z4, z5]
        
        self.wallBorder = 10
        
        super.didMove(to: view)
    }
    
    
    public override func setupBehavior() {
//        self.behaviors = [FlockBehavior(intensities: [0.15, 0.4, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 40, actionRadius: 200), AvoidZone(intensity: 1, borderMargin: 10), Seek(intensity: 0.2, prize: self.prizes[0]), Seek(intensity: 0.2, prize: self.prizes[1])]
        
        self.behaviors = [FlockBehavior(intensities: [0.15, 0.4, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 40, actionRadius: 200), AvoidZone(intensity: 1, borderMargin: 10), Seek(intensity: 0.3, prize: self.prizes[0]), Seek(intensity: 0.3, prize: self.prizes[1])]
    }
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, endFractionX: 0.2, startFractionY: 0, endFractionY: 1, canvas: canvas, allowedEdgesFractions: [.right:[EdgePair(begin: 0.9, length: 0.1)]])
        
        let zone2:Zone = Zone(startFractionX: 0.2, endFractionX: 0.8, startFractionY: 0, endFractionY: 1, canvas: canvas, allowedEdgesFractions: [.left:[EdgePair(begin: 0, length: 0.1)], .right: [EdgePair(begin: 0.9, length: 0.1)]])
        
        let zone3:Zone = Zone(startFractionX: 0.8, endFractionX: 1, startFractionY: 0, endFractionY: 1, canvas: canvas, allowedEdgesFractions: [.left:[EdgePair(begin: 0, length: 0.1)]])
        
        
        return Scenario(zones: [zone1, zone2, zone3])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        let prize1:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: Int(Float(self.agentsNum)*0.4))
        let x1 = canvas.width*0.1 - canvas.width/2
        let y1 = canvas.height*0.85 - canvas.height/2
        prize1.position = CGPoint(x: x1, y: y1)
        
        let prize2:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: Int(Float(self.agentsNum)*0.4))
        let x2 = canvas.width*0.9 - canvas.width/2
        let y2 = canvas.height*0.1 - canvas.height/2
        prize2.position = CGPoint(x: x2, y: y2)
        
        return [prize1, prize2]
    }
    
    public override func nextLevel() {
        // Set the menu with all levels
        __GLOBAL_UNLOCKED_LEVELS = 2
        __GLOBAL_POINTING_SPOT = nil
        
        let transition = SKTransition.fade(withDuration: 1)
        if let scene = GameIntro(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene, transition: transition)
        }
    }
}
