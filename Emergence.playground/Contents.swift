/*:
 ![alternate text ](fireflies.png)
 # Emergence
 ###### Enlight the world
 Emergence is a game about a world where the light has been vanished and your goal is to guide fireflies to the lamp collectors to allow the world to have light again.
 
 ## About the gameplay
 
 The game is better experienced at landscape with headphones that will allow you to imerge in this mesmerizing experience of a world where there is no light and you must surpass the obstacles to find out a path to guide the fireflies to the lamps.
 You must press and hold your finger in the screen to attract the fireflies and then guide then to the colored circles that glows when you get closer to then.
 
 ## About the game
 
 The Emergence game uses a interesting technique called swarm intelligence, that is a emergence phenomenon that I did explain better [in a blog post](https://medium.com/@caiogomes34/swarm-agents-part-1-2-38c2df98c34d?source=friends_link&sk=2d9ed4b67320a0f71815374c5fa1f9dc) . Explaining it simply the swarm intelligence principle is to use a huge amount of not so smart entities to behave together with some simple rules that allows then to become something smarter. The behavior adopted here is the algorithm describe by Craig Reynolds in 1986 to simulate the movement of birds, this was applied in the movement of the fireflies to allow them to appear beautiful in the screen.
 The game was made with four levels to allow it to be experienced in about 3 minutes, yet the first experience may be felt already in the first level and the idea behind it is to become a really puzzly game enhancing the difficulty level and enhancing the difficulty of the game with more and more challenges, yet the levels placed here are not that hard to solve.
 
 ## Next steps
 The next steps to enhance the experience in this game are to add some new species of fireflies in the scenario that behave differently in the scenario itself and will allow the puzzles become more fascinating.

 ## Copyright and Open source
 
 All the assets present in this playground are free for usage by everyone and hereby guaranteeded by their creators. The assets not made by me are the musics that were taken from dlsound and freesound.com and the images taken from flaticon.com and are free for any usage.
 
 ## Geek zone
 This zone is dedicated to anyone that enjoys understanding some techinical aspects behind the game implementation, once it is a technique with some really hard implementation tasks.
 This game was completly built over a CPU for two main reasons, the first one is as a technical challenge to extract the last bit of optimization in processing to allow it to run smooth at 60 frames per seconds at mobile devices such as an iPad, yet, for any kind of super computer this kind of computation is still really heavy because there are lots of vectorial operations to compute at complexity of O(n^2), the second reason for using the CPU processing is based in the availability of the SpriteKit as a implementation over the GPU for rendering that is way faster to implement for some applications such as this playground than to use the metal library to implement from scratch every single functio and build a game engine over the GPU processing library, those are the main reasons why the GPU after being taken in account wasn't really used.
 */


import Foundation
import PlaygroundSupport
import SpriteKit
import AVFoundation

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

// Build the audioplayer
var player:AVAudioPlayer? = nil

// Add custom fonts
addCustomFonts()

// Setup the background music
playBackgroundSound(player: &player)

if let scene = GameIntro(fileNamed: "GameScene") {
    // Setup the aspect of the scene
    scene.scaleMode = .aspectFit
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView




