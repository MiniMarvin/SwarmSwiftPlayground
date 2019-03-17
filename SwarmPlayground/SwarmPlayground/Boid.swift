//
//  Boid.swift
//  Boids
//
//     🐠 🐠
//  🐠 🐠  🐠
//    🐠 🐠 🐠
//
//  Created by Christopher Kriens on 4/5/17.

enum BoidOrientation: CGFloat {
    case north = 0
    case east = 270
    case south = 180
    case west = 90
}

import Foundation
import SpriteKit

//class Boid: SKSpriteNode {
//    var maximumFlockSpeed: CGFloat = 2
//    var maximumGoalSpeed: CGFloat = 4
//    var currentSpeed: CGFloat = 2
//    var fearThreshold: CGFloat = 100
//    var velocity = CGPoint.zero
//    var behaviors = [Behavior]()
//    let momentum: CGFloat = 6
//    let visionAngle: CGFloat = 180
//}
