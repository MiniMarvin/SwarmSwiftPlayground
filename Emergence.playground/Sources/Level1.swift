import Foundation
import SpriteKit


public class Level1 : GameScene {
    
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
        
        super.didMove(to: view)
    }
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, endFractionX: 0.5, startFractionY: 0, endFractionY: 1, canvas: self.canvas!, allowedEdgesFractions: [.right:[EdgePair(begin: 0, length: 0.2)]])
        let zone2:Zone = Zone(startFractionX: 0.5, endFractionX: 1, startFractionY: 0, endFractionY: 1, canvas: self.canvas!, allowedEdgesFractions: [.left:[EdgePair(begin: 0, length: 0.2)]])
        
        return Scenario(zones: [zone1, zone2])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        let prize:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: Int(Float(self.agentsNum)*0.8))
        let x = canvas.width*0.85 - canvas.width/2
        let y = canvas.height*0.15 - canvas.height/2
        prize.position = CGPoint(x: x, y: y)
        
        return [prize]
    }
    
    public override func nextLevel() {
        
        if self.didStartFinish { return }
        self.didStartFinish = true
        
        if __GLOBAL_UNLOCKED_LEVELS < 2 {
            __GLOBAL_UNLOCKED_LEVELS = 2
        }
        __GLOBAL_POINTING_SPOT = nil
        
        let transition = SKTransition.fade(withDuration: 1)
        
        // Dealloc every node in the scene
        for node in self.children {
            node.removeFromParent()
        }
        
        if let scene = GameIntro(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene, transition: transition)
        }
    }
}
