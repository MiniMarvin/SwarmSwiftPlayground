//: A SpriteKit based Playground
// TODO: Make a glow under the fireflies

/**
 # Emergence
 Emergence is a playground that simulate the behavior of swarms
 ## Try to enlight the world
 Fill the magic stones with fireflies to enlight the world again
 */


import Foundation
import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
//    scene.scaleMode = .aspectFill
    scene.scaleMode = .aspectFit
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView




