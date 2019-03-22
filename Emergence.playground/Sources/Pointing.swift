import Foundation
import SpriteKit

var __PRIVATE_POINTING_SIZE = CGSize(width: 0, height: 0)


public protocol Pointable {
    var pointingOutline:SKSpriteNode { get set }
}

public func setupPointing(size:CGFloat, pointingOutline:SKSpriteNode) {
    let sz = 1
    
    pointingOutline.name = "setup"
    pointingOutline.color = .red
    pointingOutline.size = CGSize(width: sz, height: sz)
    __PRIVATE_POINTING_SIZE = CGSize(width: sz, height: sz)
    pointingOutline.isHidden = false
    pointingOutline.colorBlendFactor = 1
    pointingOutline.alpha = 1
}

public func addPointing(pointingOutline:SKSpriteNode, scene:SKScene, point:CGPoint) {
    pointingOutline.size = __PRIVATE_POINTING_SIZE
    pointingOutline.alpha = 1
    pointingOutline.position = point
    if pointingOutline.parent == nil {
        scene.addChild(pointingOutline)
    }
//    pointingOutline.removeAllActions()
//    let act = SKAction.scale(by: 2, duration: 1)
//    let fade = SKAction.fadeOut(withDuration: 1)
//    let fadein = SKAction.fadeIn(withDuration: 0)
//    let reversed = SKAction.scale(by: 0.5, duration: 0)
//    let group = SKAction.group([act, fade])
//    let group1 = SKAction.group([fadein, reversed])
//
//    let sequence = SKAction.sequence([group, group1])
//    let forever = SKAction.repeatForever(sequence)
//    pointingOutline.run(forever)
    
    pointingOutline.position = point
    if pointingOutline.parent == nil {
        scene.addChild(pointingOutline)
    }
    
    if pointingOutline.children.count == 0 {
        let redTrail = SKEmitterNode(fileNamed: "trail")!
        redTrail.targetNode = scene
        redTrail.particleScale = 1
        redTrail.particleTexture = SKTexture(imageNamed: "spark")
//        redTrail.numParticlesToEmit = 60
        redTrail.particleScaleSpeed = -3
        redTrail.particleBirthRate = 30
        redTrail.particleLifetime = 0.1
        redTrail.particleColorSequence = nil;
        redTrail.particleColorBlendFactor = 1;
        redTrail.particleColor = .yellow
        redTrail.name = "trail"
//        redTrail.particleColor = .red
        pointingOutline.addChild(redTrail)
    }
    else {
        let trail = pointingOutline.childNode(withName: "trail") as! SKEmitterNode
        trail.isHidden = false
        trail.particleAlpha = 1
    }
    
    pointingOutline.isHidden = false
    
}

public func updatePointing(pointingOutline:SKSpriteNode, point:CGPoint) {
    if __GLOBAL_POINTER_IS_WORKING > 0 {
        pointingOutline.color = .yellow
        let trail = pointingOutline.childNode(withName: "trail") as! SKEmitterNode
        trail.particleColor = .yellow
    }
    else {
        pointingOutline.color = .red
        let trail = pointingOutline.childNode(withName: "trail") as! SKEmitterNode
        trail.particleColor = .red
    }
    pointingOutline.position = point
    if __GLOBAL_POINTER_IS_WORKING > 0 {
        __GLOBAL_POINTER_IS_WORKING -= 1
    }
}

public func removePointing(pointingOutline:SKSpriteNode) {
//    if pointingOutline.parent != nil {
//        pointingOutline.removeFromParent()
//    }
    let trail = pointingOutline.childNode(withName: "trail") as! SKEmitterNode
    trail.isHidden = true
    trail.particleAlpha = 0
    pointingOutline.isHidden = true
    __GLOBAL_POINTER_IS_WORKING = 0
}
