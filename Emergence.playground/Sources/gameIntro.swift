import Foundation
import SpriteKit

public class gameIntro:GameScene {
    
    // Variable to tell how many levels have been unlocked already
    var unlockedLevels: Int = 0
    
    public override func didMove(to view: SKView) {
        var arr:[ZoneBuilder] = []
        let frac = 20
        let n = 600/((frac/2)*(frac/2))
        
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
        self.behaviors = [FlockBehavior(intensities: [0.1, 0.4, 0.4]), Bound(intensity: 4), SeekFinger(intensity: 0.8, centerRadius: 0, actionRadius: 5000), AvoidZone(intensity: 1)]
    }
    
    
    public override func levelZone(canvas:CGRect) -> Scenario {
        let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
        
        return Scenario(zones: [zone1])
    }
    
    public override func levelPrizes(canvas:CGRect) -> [Prize] {
        var allPrizes:[Prize] = []
        
        let prize1:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: self.agentsNum)
        let x = canvas.width*0.1 - canvas.width/2
        let y = canvas.height*0.7 - canvas.height/2
        prize1.position = CGPoint(x: x, y: y)
        allPrizes.append(prize1)
        
        if self.unlockedLevels > 0 {
            let prize2:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: self.agentsNum)
            let x = canvas.width*0.25 - canvas.width/2
            let y = canvas.height*0.7 - canvas.height/2
            prize2.position = CGPoint(x: x, y: y)
        }
        
        return allPrizes
    }
    
    public override func nextLevel() {
        let transition = SKTransition.fade(withDuration: 1)
        if let scene = Level1(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFit
            self.view?.presentScene(scene, transition: transition)
        }
    }
}
