import Foundation
import SpriteKit


public class Level0 : GameScene {
    
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        let frac = 4
        let n = 200/((frac/2)*(frac/2))
        
        for pi in 0...(frac-1) {
            for pj in 0...(frac-1) {
                if pi >= 2 || pj  < 2 { continue }
                let i = CGFloat(pi)
                let j = CGFloat(pj)
                let f = CGFloat(frac)
                
                let z = ZoneBuilder(intervalX: (i/f)...((i+1)/f), intervalY: (j/f)...((j+1)/f), numOfAgents: n)
                arr.append(z)
            }
        }
        self.fireflies = arr
        
        // Call the super class initialization
        super.didMove(to: view)
    }
    
    public override func setupBehavior() {
        self.behaviors = [FlockBehavior(intensities: [0.1, 0.4, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 40, actionRadius: 200), AvoidZone(intensity: 1), Seek(intensity: 0.1, prize: self.prizes[0])]
    }
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        let prize:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: Int(Float(self.agentsNum)*0.8))
        let x = canvas.width*0.85 - canvas.width/2
        let y = canvas.height*0.15 - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        
        return [prize]
    }
    
    public override func nextLevel() {
        let transition = SKTransition.fade(withDuration: 1)
        
        // Dealloc every node in the scene
        for node in self.children {
            node.removeFromParent()
        }
        
        if let scene = Level1(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene, transition: transition)
        }
    }
}
