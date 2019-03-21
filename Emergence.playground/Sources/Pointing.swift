import Foundation
import SpriteKit

var __PRIVATE_POINTING_SIZE = CGSize(width: 0, height: 0)


public protocol Pointable {
    var pointingOutline:SKSpriteNode { get set }
}

public func setupPointing(size:CGFloat, pointingOutline:SKSpriteNode) {
    pointingOutline.name = "setup"
    pointingOutline.color = .red
    pointingOutline.size = CGSize(width: size, height: size)
    __PRIVATE_POINTING_SIZE = CGSize(width: size, height: size)
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
    pointingOutline.removeAllActions()
    let act = SKAction.scale(by: 2, duration: 1)
    let fade = SKAction.fadeOut(withDuration: 1)
    let fadein = SKAction.fadeIn(withDuration: 0)
    let reversed = SKAction.scale(by: 0.5, duration: 0)
    let group = SKAction.group([act, fade])
    let group1 = SKAction.group([fadein, reversed])
    
    let sequence = SKAction.sequence([group, group1])
    let forever = SKAction.repeatForever(sequence)
    pointingOutline.run(forever)
    
    pointingOutline.isHidden = false
}

public func updatePointing(pointingOutline:SKSpriteNode, point:CGPoint) {
    if __GLOBAL_POINTER_IS_WORKING > 0 {
        pointingOutline.color = .yellow
    }
    else {
        pointingOutline.color = .red
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
    pointingOutline.isHidden = true
    __GLOBAL_POINTER_IS_WORKING = 0
}
