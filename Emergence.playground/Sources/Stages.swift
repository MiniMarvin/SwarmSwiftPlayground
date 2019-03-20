//
//  Stages.swift
//  SwarmPlayground2
//
//  Created by Caio Gomes on 20/03/19.
//  Copyright © 2019 Caio Gomes. All rights reserved.
//

import Foundation
import SpriteKit

func Zone0(canvas:CGRect) -> Scenario {
    let zone1:Zone = Zone(startFractionX: 0, startFractionY: 0.4, widthFraction: 1, heightFraction: 0.2, canvas: canvas, allowedEdgesFractions: [:])
    //    let zone2:Zone = Zone(startFractionX: 0.6, startFractionY: 1, widthFraction: 1, heightFraction: 1, canvas: canvas, allowedEdgesFractions: [:])
    
    return Scenario(zones: [zone1])
}

func prize0(canvas:CGRect) -> Prize {
    let prize:Prize = Prize(withTexture: "spark.png", size: 60, countToFill: 300)
    let x = canvas.width*0.8 - canvas.width/2
    let y = canvas.height*0.5 - canvas.height/2
    prize.position = CGPoint(x: x, y: y)
    return prize
}
