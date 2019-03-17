//
//  GameScene.swift
//  SwarmPlayground
//
//  Created by Caio Gomes on 16/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import SpriteKit
import GameplayKit

public class GameScene: SKScene {
    var agentsNum:Int = 100
    var agents:[Boid2D] = []
    
    public override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.white
        var agents:[Boid2D] = []
        
        // populate
        for i in 0...(agentsNum - 1) {
            let bd = Boid2D()
            bd.id = i
            agents.append(bd)
        }
        
        // Setup the agents in the board
        agents.forEach { agent in
            self.addChild(agent.baseNode)
        }
        
        // Update the class variable
        self.agents = agents
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        self.agents.forEach({node in
            node.alignProperly(neightBoorHood: self.agents, maxMagnetude: 50)
//            node.adjustPosition(canvas: self.frame)
            node.setProperties()
        })
    }
}
